;; ============================================================
;; Contract: phaseweaver.clar
;; Purpose : On-chain feature rollout & staging engine
;; ============================================================

;; -------------------------
;; ERRORS
;; -------------------------
(define-constant ERR-NOT-AUTHORIZED     (err u14001))
(define-constant ERR-FEATURE-NOT-FOUND  (err u14002))
(define-constant ERR-INVALID-STAGE      (err u14003))

;; -------------------------
;; STAGES
;; -------------------------
;; 0 = disabled
;; 1 = alpha
;; 2 = beta
;; 3 = production

(define-constant STAGE-DISABLED u0)
(define-constant STAGE-ALPHA u1)
(define-constant STAGE-BETA u2)
(define-constant STAGE-PROD u3)

;; -------------------------
;; FEATURE STORAGE
;; -------------------------

(define-map features
  { feature: (string-ascii 32) }
  {
    stage: uint,
    updated-at: uint
  }
)

;; -------------------------
;; AUTHORIZATION
;; -------------------------

(define-data-var contract-owner (optional principal) none)

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (or (is-none (var-get contract-owner)) (authorized?)) ERR-NOT-AUTHORIZED)
    (var-set contract-owner (some new-owner))
    (ok true)
  )
)

(define-read-only (authorized?)
  (match (var-get contract-owner)
    owner (is-eq tx-sender owner)
    true
  )
)

;; -------------------------
;; FEATURE MANAGEMENT
;; -------------------------

(define-public (set-feature-stage
  (feature (string-ascii 32))
  (stage uint)
)
  (begin
    (asserts! (authorized?) ERR-NOT-AUTHORIZED)
    (asserts!
      (or
        (is-eq stage STAGE-DISABLED)
        (is-eq stage STAGE-ALPHA)
        (is-eq stage STAGE-BETA)
        (is-eq stage STAGE-PROD)
      )
      ERR-INVALID-STAGE
    )

    (map-set features
      { feature: feature }
      { stage: stage, updated-at: u0 }
    )

    (ok stage)
  )
)

(define-public (remove-feature (feature (string-ascii 32)))
  (begin
    (asserts! (authorized?) ERR-NOT-AUTHORIZED)
    (map-delete features { feature: feature })
    (ok true)
  )
)

;; -------------------------
;; READ INTERFACE (CRITICAL)
;; -------------------------

(define-read-only (feature-stage
  (feature (string-ascii 32))
)
  (match (map-get? features { feature: feature })
    data (get stage data)
    STAGE-DISABLED
  )
)

(define-read-only (feature-active?
  (feature (string-ascii 32))
  (min-stage uint)
)
  (>= (feature-stage feature) min-stage)
)

(define-read-only (feature-info
  (feature (string-ascii 32))
)
  (match (map-get? features { feature: feature })
    data (ok data)
    ERR-FEATURE-NOT-FOUND
  )
)
