
;; exact
;; <add a description here>

;; ;; ;; ;; ;; Constants ;; ;; ;; ;; ;;
;;
(define-constant failed-to-mint-err (err 1))

;; ;; ;; ;; ;; Data Maps and Vars ;; ;; ;; ;; ;;
;;

;; NFT Variable
(define-non-fungible-token ex-token uint)

;; Storage

;; number of tokens a particular university owns
(define-map tokens-count { owner: principal } { count: int })

;; data map to store university-name, student-name, degree
(define-map degree-data 
    {token-id: uint}
    (tuple (university-name (string-ascii 100)) (student-name (string-ascii 100)) (degree (string-ascii 100)))
)

;; ;; ;; ;; ;; private functions ;; ;; ;; ;; ;;
;;
;; Gets the amount of tokens owned by the specified address.
(define-private (balance-of (account principal))
  (default-to 0
    (get count
         (map-get? tokens-count (tuple (owner account))))))

;; Checks whether the owner owns the token or not
(define-private (is-owner (actor principal) (token-id uint))
  (is-eq actor
    (unwrap! (nft-get-owner? ex-token token-id) false)
  )
)

;; Mint new tokens
(define-private (mint! 
  (owner principal) 
  (token-id uint) 
  (university-name (string-ascii 100)) 
  (student-name (string-ascii 100)) 
  (degree (string-ascii 100)))

    (if (register-token owner token-id)
        (begin
          (map-set degree-data
            {token-id: token-id}
            (tuple (university-name university-name) (student-name student-name) (degree degree))
          )
          (ok token-id)
        )
        failed-to-mint-err
    )
)

;; Register token
(define-private (register-token (new-owner principal) (token-id uint))
    (let 
        ((current-balance (balance-of new-owner)))
        (begin
            (unwrap! (nft-mint? ex-token token-id new-owner) false)
            (map-set tokens-count
                {owner: new-owner}
                {count: (+ 1 current-balance)}
            )
            true
        )
    )
)

;; ;; ;; ;; ;; public functions ;; ;; ;; ;; ;; ;;
;;
;; Gets the owner of the specified token ID.
(define-public (owner-of? (token-id uint))
  (ok (nft-get-owner? ex-token token-id))
)

;; Initialize the contract
(begin
  (unwrap! 
    (mint! 'ST398K1WZTBVY6FE2YEHM6HP20VSNVSSPJTW0D53M u1000 "LUMS" "Suleman" "BS-CS") 
    false
  )
)