
;; exact
;; <add a description here>

;; constants
;;

;; data maps and vars
;;

;; NFT Variable
(define-non-fungible-token ex-token uint)

;; Storage
;; Data map to store university-name, student-name, degree 
(define-map tokens-spender { token-id: uint } { spender: principal })
(define-map tokens-count { owner: principal } { count: int })
(define-map accounts-operator (tuple (operator principal) (account principal)) { is-approved: bool })

;; private functions
;;
;; Gets the amount of tokens owned by the specified address.
(define-private (balance-of (account principal))
    (default-to 0 
        (get count
            (map-get? tokens-count (tuple (owner account)))
        )
    )
)
;; Gets the owner of the specified token ID.
(define-public (owner-of? (token-id uint))
    (ok (nft-get-owner? ex-token token-id))
)

;; Gets the approved address for a token ID, or zero if no address set (approved method in ERC721)
(define-private (is-spender-approved (spender principal) (token-id uint))
    (let ((approved-spender 
            (unwrap! 
                (get spender
                    (map-get? tokens-spender (tuple (token-id token-id)))
                )
                false
            )))
        (is-eq approved-spender spender)
    )
)

;; Tells whether an operator is approved by a given owner (isApprovedForAll method in ERC721)
(define-private (is-operator-approved (account principal) (operator principal))
    (unwrap!
        (get is-approved
            (map-get? accounts-operator (tuple (operator operator) (account account))) 
        )
        false
    )  
)

(define-private (is-owner (actor principal) (token-id uint))
  (is-eq actor
    (unwrap! (nft-get-owner? ex-token token-id) false)
  )
)

;; public functions
;;
