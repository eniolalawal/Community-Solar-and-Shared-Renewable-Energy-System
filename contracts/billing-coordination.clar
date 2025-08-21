;; Billing Coordination and Net Metering Contract
;; Manages transparent billing and utility coordination

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-BILL-NOT-FOUND (err u301))
(define-constant ERR-INVALID-AMOUNT (err u302))
(define-constant ERR-PAYMENT-FAILED (err u303))
(define-constant ERR-BILL-ALREADY-PAID (err u304))
(define-constant ERR-INVALID-RATE (err u305))

;; Data Variables
(define-data-var utility-rate-per-kwh uint u12) ;; 12 cents per kWh in micro-units
(define-data-var net-metering-rate uint u10) ;; 10 cents per kWh credit
(define-data-var total-bills-issued uint u0)
(define-data-var total-payments-processed uint u0)

;; Data Maps
(define-map billing-records
  { subscriber: principal, billing-period: uint }
  {
    energy-consumed: uint,
    energy-credits-used: uint,
    net-energy-cost: uint,
    utility-charges: uint,
    solar-credits: uint,
    total-amount-due: uint,
    payment-status: (string-ascii 20),
    due-date: uint,
    payment-date: uint
  }
)

(define-map net-metering-records
  { subscriber: principal, period: uint }
  {
    energy-fed-to-grid: uint,
    energy-consumed-from-grid: uint,
    net-energy-balance: int,
    credit-amount: uint,
    billing-adjustment: int
  }
)

(define-map payment-history
  { subscriber: principal, payment-id: uint }
  {
    amount-paid: uint,
    payment-method: (string-ascii 30),
    transaction-date: uint,
    billing-period: uint,
    confirmation-number: (string-ascii 50)
  }
)

(define-map utility-coordination
  { period: uint }
  {
    total-grid-feed-in: uint,
    total-grid-consumption: uint,
    net-settlement: int,
    coordination-complete: bool,
    settlement-date: uint
  }
)

;; Public Functions

;; Generate bill for subscriber
(define-public (generate-bill (subscriber principal) (billing-period uint) (energy-consumed uint) (energy-credits-used uint))
  (let (
    (utility-charges (* energy-consumed (var-get utility-rate-per-kwh)))
    (solar-credits (* energy-credits-used (var-get net-metering-rate)))
    (net-cost (if (> utility-charges solar-credits) (- utility-charges solar-credits) u0))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> energy-consumed u0) ERR-INVALID-AMOUNT)

    (map-set billing-records
      { subscriber: subscriber, billing-period: billing-period }
      {
        energy-consumed: energy-consumed,
        energy-credits-used: energy-credits-used,
        net-energy-cost: net-cost,
        utility-charges: utility-charges,
        solar-credits: solar-credits,
        total-amount-due: net-cost,
        payment-status: "pending",
        due-date: (+ block-height u720), ;; ~30 days
        payment-date: u0
      }
    )

    (var-set total-bills-issued (+ (var-get total-bills-issued) u1))
    (ok true)
  )
)

;; Process payment for bill
(define-public (process-payment (subscriber principal) (billing-period uint) (payment-id uint) (amount-paid uint) (payment-method (string-ascii 30)))
  (let (
    (bill-data (unwrap! (map-get? billing-records { subscriber: subscriber, billing-period: billing-period }) ERR-BILL-NOT-FOUND))
  )
    (asserts! (or (is-eq tx-sender subscriber) (is-eq tx-sender CONTRACT-OWNER)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get payment-status bill-data) "pending") ERR-BILL-ALREADY-PAID)
    (asserts! (>= amount-paid (get total-amount-due bill-data)) ERR-INVALID-AMOUNT)

    (map-set billing-records
      { subscriber: subscriber, billing-period: billing-period }
      (merge bill-data {
        payment-status: "paid",
        payment-date: block-height ;; replaced stacks-block-height with block-height
      })
    )

    (map-set payment-history
      { subscriber: subscriber, payment-id: payment-id }
      {
        amount-paid: amount-paid,
        payment-method: payment-method,
        transaction-date: block-height, ;; replaced stacks-block-height with block-height
        billing-period: billing-period,
        confirmation-number: "CONF-12345"
      }
    )

    (var-set total-payments-processed (+ (var-get total-payments-processed) u1))
    (ok true)
  )
)

;; Record net metering data
(define-public (record-net-metering (subscriber principal) (period uint) (energy-fed uint) (energy-consumed uint))
  (let (
    (net-balance (- (to-int energy-fed) (to-int energy-consumed)))
    (credit-amount (if (> energy-fed energy-consumed) (* (- energy-fed energy-consumed) (var-get net-metering-rate)) u0))
    (billing-adjustment (if (> energy-fed energy-consumed) (to-int credit-amount) (- (to-int (* (- energy-consumed energy-fed) (var-get utility-rate-per-kwh))))))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set net-metering-records
      { subscriber: subscriber, period: period }
      {
        energy-fed-to-grid: energy-fed,
        energy-consumed-from-grid: energy-consumed,
        net-energy-balance: net-balance,
        credit-amount: credit-amount,
        billing-adjustment: billing-adjustment
      }
    )

    (ok true)
  )
)

;; Coordinate with utility company
(define-public (coordinate-with-utility (period uint) (total-feed-in uint) (total-consumption uint))
  (let (
    (net-settlement (- (to-int total-feed-in) (to-int total-consumption)))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set utility-coordination
      { period: period }
      {
        total-grid-feed-in: total-feed-in,
        total-grid-consumption: total-consumption,
        net-settlement: net-settlement,
        coordination-complete: true,
        settlement-date: block-height ;; replaced stacks-block-height with block-height
      }
    )

    (ok true)
  )
)

;; Update utility rates
(define-public (update-utility-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> new-rate u0) ERR-INVALID-RATE)

    (var-set utility-rate-per-kwh new-rate)
    (ok true)
  )
)

;; Update net metering rate
(define-public (update-net-metering-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> new-rate u0) ERR-INVALID-RATE)

    (var-set net-metering-rate new-rate)
    (ok true)
  )
)

;; Read-only Functions

;; Get billing record
(define-read-only (get-billing-record (subscriber principal) (billing-period uint))
  (map-get? billing-records { subscriber: subscriber, billing-period: billing-period })
)

;; Get net metering record
(define-read-only (get-net-metering-record (subscriber principal) (period uint))
  (map-get? net-metering-records { subscriber: subscriber, period: period })
)

;; Get payment history
(define-read-only (get-payment-history (subscriber principal) (payment-id uint))
  (map-get? payment-history { subscriber: subscriber, payment-id: payment-id })
)

;; Get utility coordination data
(define-read-only (get-utility-coordination (period uint))
  (map-get? utility-coordination { period: period })
)

;; Get current utility rate
(define-read-only (get-utility-rate)
  (var-get utility-rate-per-kwh)
)

;; Get net metering rate
(define-read-only (get-net-metering-rate)
  (var-get net-metering-rate)
)

;; Get total bills issued
(define-read-only (get-total-bills-issued)
  (var-get total-bills-issued)
)

;; Get total payments processed
(define-read-only (get-total-payments-processed)
  (var-get total-payments-processed)
)

;; Calculate bill amount
(define-read-only (calculate-bill-amount (energy-consumed uint) (energy-credits uint))
  (let (
    (utility-charges (* energy-consumed (var-get utility-rate-per-kwh)))
    (solar-credits (* energy-credits (var-get net-metering-rate)))
  )
    (if (> utility-charges solar-credits) (- utility-charges solar-credits) u0)
  )
)
