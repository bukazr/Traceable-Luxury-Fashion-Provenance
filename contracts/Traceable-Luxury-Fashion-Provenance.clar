;; title: Traceable-Luxury-Fashion-Provenance

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-not-found (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-invalid-stage (err u104))
(define-constant err-unauthorized (err u105))
(define-constant err-invalid-origin (err u106))

(define-non-fungible-token luxury-garment uint)

(define-data-var token-id-nonce uint u0)

(define-map garment-metadata
    uint
    {
        name: (string-ascii 100),
        brand: (string-ascii 50),
        material-origin: (string-ascii 100),
        production-location: (string-ascii 100),
        created-at: uint,
        current-stage: (string-ascii 20),
        ethical-certified: bool
    }
)

(define-map supply-chain-stages
    { token-id: uint, stage: (string-ascii 20) }
    {
        location: (string-ascii 100),
        timestamp: uint,
        verified-by: principal,
        notes: (string-ascii 200)
    }
)

(define-map authorized-verifiers principal bool)

(define-map garment-ownership-history
    { token-id: uint, index: uint }
    {
        owner: principal,
        timestamp: uint,
        price: (optional uint)
    }
)

(define-map ownership-history-count uint uint)

(define-read-only (get-last-token-id)
    (ok (var-get token-id-nonce))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (some "https://luxury-fashion.io/metadata/"))
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? luxury-garment token-id))
)

(define-read-only (get-garment-metadata (token-id uint))
    (ok (map-get? garment-metadata token-id))
)

(define-read-only (get-supply-chain-stage (token-id uint) (stage (string-ascii 20)))
    (ok (map-get? supply-chain-stages { token-id: token-id, stage: stage }))
)

(define-read-only (is-verifier (user principal))
    (default-to false (map-get? authorized-verifiers user))
)

(define-read-only (get-ownership-history (token-id uint) (index uint))
    (ok (map-get? garment-ownership-history { token-id: token-id, index: index }))
)

(define-read-only (get-ownership-history-length (token-id uint))
    (ok (default-to u0 (map-get? ownership-history-count token-id)))
)

(define-public (mint-garment 
    (name (string-ascii 100))
    (brand (string-ascii 50))
    (material-origin (string-ascii 100))
    (production-location (string-ascii 100))
    (ethical-certified bool))
    (let
        (
            (new-token-id (+ (var-get token-id-nonce) u1))
            (current-block (unwrap-panic (get-stacks-block-info? time burn-block-height)))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (nft-mint? luxury-garment new-token-id tx-sender))
        (map-set garment-metadata new-token-id {
            name: name,
            brand: brand,
            material-origin: material-origin,
            production-location: production-location,
            created-at: current-block,
            current-stage: "minted",
            ethical-certified: ethical-certified
        })
        (map-set supply-chain-stages 
            { token-id: new-token-id, stage: "minted" }
            {
                location: production-location,
                timestamp: current-block,
                verified-by: tx-sender,
                notes: "Initial minting"
            }
        )
        (map-set garment-ownership-history
            { token-id: new-token-id, index: u0 }
            {
                owner: tx-sender,
                timestamp: current-block,
                price: none
            }
        )
        (map-set ownership-history-count new-token-id u1)
        (var-set token-id-nonce new-token-id)
        (ok new-token-id)
    )
)

(define-public (add-supply-chain-stage 
    (token-id uint)
    (stage (string-ascii 20))
    (location (string-ascii 100))
    (notes (string-ascii 200)))
    (let
        (
            (token-owner (unwrap! (nft-get-owner? luxury-garment token-id) err-token-not-found))
            (current-block (unwrap-panic (get-stacks-block-info? time burn-block-height)))
            (metadata (unwrap! (map-get? garment-metadata token-id) err-token-not-found))
        )
        (asserts! (or (is-eq tx-sender contract-owner) (default-to false (map-get? authorized-verifiers tx-sender))) err-unauthorized)
        (map-set supply-chain-stages
            { token-id: token-id, stage: stage }
            {
                location: location,
                timestamp: current-block,
                verified-by: tx-sender,
                notes: notes
            }
        )
        (map-set garment-metadata token-id
            (merge metadata { current-stage: stage })
        )
        (ok true)
    )
)

(define-public (transfer-garment (token-id uint) (sender principal) (recipient principal))
    (let
        (
            (current-owner (unwrap! (nft-get-owner? luxury-garment token-id) err-token-not-found))
            (current-block (unwrap-panic (get-stacks-block-info? time burn-block-height)))
            (history-length (default-to u0 (map-get? ownership-history-count token-id)))
        )
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (asserts! (is-eq current-owner sender) err-not-token-owner)
        (try! (nft-transfer? luxury-garment token-id sender recipient))
        (map-set garment-ownership-history
            { token-id: token-id, index: history-length }
            {
                owner: recipient,
                timestamp: current-block,
                price: none
            }
        )
        (map-set ownership-history-count token-id (+ history-length u1))
        (ok true)
    )
)

(define-public (transfer-garment-with-price (token-id uint) (sender principal) (recipient principal) (price uint))
    (let
        (
            (current-owner (unwrap! (nft-get-owner? luxury-garment token-id) err-token-not-found))
            (current-block (unwrap-panic (get-stacks-block-info? time burn-block-height)))
            (history-length (default-to u0 (map-get? ownership-history-count token-id)))
        )
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (asserts! (is-eq current-owner sender) err-not-token-owner)
        (try! (nft-transfer? luxury-garment token-id sender recipient))
        (map-set garment-ownership-history
            { token-id: token-id, index: history-length }
            {
                owner: recipient,
                timestamp: current-block,
                price: (some price)
            }
        )
        (map-set ownership-history-count token-id (+ history-length u1))
        (ok true)
    )
)

(define-public (add-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set authorized-verifiers verifier true))
    )
)

(define-public (remove-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-delete authorized-verifiers verifier))
    )
)

(define-public (update-ethical-certification (token-id uint) (certified bool))
    (let
        (
            (metadata (unwrap! (map-get? garment-metadata token-id) err-token-not-found))
        )
        (asserts! (or (is-eq tx-sender contract-owner) (default-to false (map-get? authorized-verifiers tx-sender))) err-unauthorized)
        (ok (map-set garment-metadata token-id
            (merge metadata { ethical-certified: certified })
        ))
    )
)

(define-read-only (verify-authenticity (token-id uint))
    (let
        (
            (metadata (unwrap! (map-get? garment-metadata token-id) err-token-not-found))
            (owner (unwrap! (nft-get-owner? luxury-garment token-id) err-token-not-found))
        )
        (ok {
            is-authentic: true,
            owner: owner,
            brand: (get brand metadata),
            ethical-certified: (get ethical-certified metadata),
            current-stage: (get current-stage metadata)
        })
    )
)
