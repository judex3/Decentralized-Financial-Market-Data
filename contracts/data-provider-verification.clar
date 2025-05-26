;; Data Provider Verification Contract
;; Manages verification and registration of data providers

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PROVIDER_EXISTS (err u101))
(define-constant ERR_PROVIDER_NOT_FOUND (err u102))
(define-constant ERR_INVALID_REPUTATION (err u103))

;; Data provider structure
(define-map data-providers
  { provider: principal }
  {
    verified: bool,
    reputation-score: uint,
    registration-block: uint,
    total-data-points: uint,
    accuracy-rating: uint
  }
)

;; Verification requests
(define-map verification-requests
  { request-id: uint }
  {
    provider: principal,
    requested-at: uint,
    status: (string-ascii 20)
  }
)

(define-data-var next-request-id uint u1)

;; Register as a data provider
(define-public (register-provider)
  (let ((provider tx-sender))
    (asserts! (is-none (map-get? data-providers { provider: provider })) ERR_PROVIDER_EXISTS)
    (map-set data-providers
      { provider: provider }
      {
        verified: false,
        reputation-score: u0,
        registration-block: block-height,
        total-data-points: u0,
        accuracy-rating: u0
      }
    )
    (ok true)
  )
)

;; Verify a data provider (only contract owner)
(define-public (verify-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? data-providers { provider: provider })) ERR_PROVIDER_NOT_FOUND)
    (map-set data-providers
      { provider: provider }
      (merge (unwrap-panic (map-get? data-providers { provider: provider }))
        { verified: true }
      )
    )
    (ok true)
  )
)

;; Update provider reputation
(define-public (update-reputation (provider principal) (new-score uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (<= new-score u100) ERR_INVALID_REPUTATION)
    (asserts! (is-some (map-get? data-providers { provider: provider })) ERR_PROVIDER_NOT_FOUND)
    (map-set data-providers
      { provider: provider }
      (merge (unwrap-panic (map-get? data-providers { provider: provider }))
        { reputation-score: new-score }
      )
    )
    (ok true)
  )
)

;; Get provider info
(define-read-only (get-provider-info (provider principal))
  (map-get? data-providers { provider: provider })
)

;; Check if provider is verified
(define-read-only (is-verified-provider (provider principal))
  (match (map-get? data-providers { provider: provider })
    provider-data (get verified provider-data)
    false
  )
)
