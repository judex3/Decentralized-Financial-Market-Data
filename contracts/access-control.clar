;; Access Control Contract
;; Manages data permissions and access rights

(define-constant ERR_UNAUTHORIZED (err u400))
(define-constant ERR_ACCESS_DENIED (err u401))
(define-constant ERR_INVALID_PERMISSION (err u402))

;; Permission levels
(define-constant PERMISSION_READ u1)
(define-constant PERMISSION_WRITE u2)
(define-constant PERMISSION_ADMIN u3)

;; Access permissions
(define-map access-permissions
  { user: principal, resource: (string-ascii 64) }
  {
    permission-level: uint,
    granted-by: principal,
    granted-at: uint,
    expires-at: (optional uint)
  }
)

;; Resource definitions
(define-map resources
  { resource-id: (string-ascii 64) }
  {
    owner: principal,
    resource-type: (string-ascii 32),
    public-access: bool,
    created-at: uint
  }
)

;; Access logs
(define-map access-logs
  { log-id: uint }
  {
    user: principal,
    resource: (string-ascii 64),
    action: (string-ascii 32),
    timestamp: uint,
    success: bool
  }
)

(define-data-var next-log-id uint u1)

;; Create resource
(define-public (create-resource
  (resource-id (string-ascii 64))
  (resource-type (string-ascii 32))
  (public-access bool))
  (begin
    (map-set resources
      { resource-id: resource-id }
      {
        owner: tx-sender,
        resource-type: resource-type,
        public-access: public-access,
        created-at: block-height
      }
    )
    (ok true)
  )
)

;; Grant permission
(define-public (grant-permission
  (user principal)
  (resource (string-ascii 64))
  (permission-level uint)
  (expires-at (optional uint)))
  (let ((resource-info (unwrap! (map-get? resources { resource-id: resource }) ERR_UNAUTHORIZED)))
    (asserts! (is-eq tx-sender (get owner resource-info)) ERR_UNAUTHORIZED)
    (asserts! (<= permission-level PERMISSION_ADMIN) ERR_INVALID_PERMISSION)
    (map-set access-permissions
      { user: user, resource: resource }
      {
        permission-level: permission-level,
        granted-by: tx-sender,
        granted-at: block-height,
        expires-at: expires-at
      }
    )
    (ok true)
  )
)

;; Check access
(define-public (check-access
  (user principal)
  (resource (string-ascii 64))
  (required-permission uint))
  (let (
    (resource-info (unwrap! (map-get? resources { resource-id: resource }) ERR_UNAUTHORIZED))
    (permission (map-get? access-permissions { user: user, resource: resource }))
  )
    (let ((has-access
      (or
        (get public-access resource-info)
        (is-eq user (get owner resource-info))
        (match permission
          perm (>= (get permission-level perm) required-permission)
          false
        )
      )))
      (log-access user resource "check" has-access)
      (if has-access (ok true) ERR_ACCESS_DENIED)
    )
  )
)

;; Log access attempt
(define-private (log-access
  (user principal)
  (resource (string-ascii 64))
  (action (string-ascii 32))
  (success bool))
  (let ((log-id (var-get next-log-id)))
    (map-set access-logs
      { log-id: log-id }
      {
        user: user,
        resource: resource,
        action: action,
        timestamp: block-height,
        success: success
      }
    )
    (var-set next-log-id (+ log-id u1))
    log-id
  )
)

;; Get permission info
(define-read-only (get-permission-info (user principal) (resource (string-ascii 64)))
  (map-get? access-permissions { user: user, resource: resource })
)

;; Get resource info
(define-read-only (get-resource-info (resource-id (string-ascii 64)))
  (map-get? resources { resource-id: resource-id })
)
