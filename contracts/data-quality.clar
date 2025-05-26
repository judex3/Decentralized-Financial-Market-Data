;; Data Quality Contract
;; Ensures information accuracy and manages quality metrics

(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_INVALID_QUALITY_SCORE (err u201))
(define-constant ERR_DATA_NOT_FOUND (err u202))

;; Data quality metrics
(define-map data-quality
  { data-id: (string-ascii 64) }
  {
    provider: principal,
    quality-score: uint,
    validation-count: uint,
    last-updated: uint,
    accuracy-votes: uint,
    total-votes: uint
  }
)

;; Quality validators
(define-map quality-validators
  { validator: principal }
  {
    reputation: uint,
    total-validations: uint,
    correct-validations: uint
  }
)

;; Submit data quality assessment
(define-public (submit-quality-assessment
  (data-id (string-ascii 64))
  (provider principal)
  (quality-score uint))
  (begin
    (asserts! (<= quality-score u100) ERR_INVALID_QUALITY_SCORE)
    (map-set data-quality
      { data-id: data-id }
      {
        provider: provider,
        quality-score: quality-score,
        validation-count: u1,
        last-updated: block-height,
        accuracy-votes: u0,
        total-votes: u0
      }
    )
    (ok true)
  )
)

;; Vote on data accuracy
(define-public (vote-accuracy (data-id (string-ascii 64)) (is-accurate bool))
  (let ((current-data (unwrap! (map-get? data-quality { data-id: data-id }) ERR_DATA_NOT_FOUND)))
    (map-set data-quality
      { data-id: data-id }
      (merge current-data
        {
          accuracy-votes: (if is-accurate
            (+ (get accuracy-votes current-data) u1)
            (get accuracy-votes current-data)
          ),
          total-votes: (+ (get total-votes current-data) u1)
        }
      )
    )
    (ok true)
  )
)

;; Register as quality validator
(define-public (register-validator)
  (begin
    (map-set quality-validators
      { validator: tx-sender }
      {
        reputation: u50,
        total-validations: u0,
        correct-validations: u0
      }
    )
    (ok true)
  )
)

;; Get data quality info
(define-read-only (get-quality-info (data-id (string-ascii 64)))
  (map-get? data-quality { data-id: data-id })
)

;; Calculate accuracy percentage
(define-read-only (get-accuracy-percentage (data-id (string-ascii 64)))
  (match (map-get? data-quality { data-id: data-id })
    data-info
      (if (> (get total-votes data-info) u0)
        (some (/ (* (get accuracy-votes data-info) u100) (get total-votes data-info)))
        (some u0)
      )
    none
  )
)
