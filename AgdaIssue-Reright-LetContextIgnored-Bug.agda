open import Agda.Primitive
open import Agda.Builtin.List
  using (List; [])
  renaming (_∷_ to _∷ₗ_)

open import Agda.Builtin.List
  renaming (List to 𝑳
           ;[] to ∅
           ; _∷_ to _∷ₗ_
           )


open import Agda.Builtin.Equality
open import Prelude.Empty

open import Prelude
  using ( eraseEquality
        ; eraseNegation
        )

data Dec {a} (P : Set a) : Set a where
  yes : P → Dec P
  no  : ¬ P → Dec P



sym : ∀ {a} {A : Set a} {x y : A} → x ≡ y → y ≡ x
sym refl = refl

open import Agda.Builtin.Nat using (suc; _-_; _+_) renaming (Nat to ℕ)

REL : ∀ {a b} → Set a → Set b → (ℓ : Level) → Set (a ⊔ b ⊔ Prelude.lsuc ℓ)
REL A B ℓ = A → B → Set ℓ

Rel : ∀ {a} → Set a → (ℓ : Level) → Set (a ⊔ Prelude.lsuc ℓ)
Rel A ℓ = REL A A ℓ

_Respects_ : ∀ {a ℓ₁ ℓ₂} {A : Set a} → (A → Set ℓ₁) → Rel A ℓ₂ → Set _
P Respects _∼_ = ∀ {x y} → x ∼ y → P x → P y

Substitutive : ∀ {a ℓ₁} {A : Set a} → Rel A ℓ₁ → (ℓ₂ : Level) → Set _
Substitutive {A = A} _∼_ p = (P : A → Set p) → P Respects _∼_

subst : ∀ {a p} {A : Set a} → Substitutive (_≡_ {A = A}) p
subst P refl p = p

sucsuc≡ : ∀ {a b : ℕ} → suc a ≡ suc b → a ≡ b
sucsuc≡ refl = refl

_≟_ : (a : ℕ) → (b : ℕ) → Dec (a ≡ b)
Prelude.zero ≟ Prelude.zero = yes refl
Prelude.zero ≟ suc b = no (λ ())
suc a ≟ Prelude.zero = no (λ ())
suc a ≟ suc b with a ≟ b
… | yes eq rewrite eq = yes refl
… | no neq = no (λ x → ⊥-elim (neq (sucsuc≡ x)))

_≢_ : ∀ {a} {A : Set a} → A → A → Set a
A ≢ B = ¬ A ≡ B

data 𝕃 {𝑨} (𝐴 : Set 𝑨) : Set 𝑨
data _∉_ {𝑨} {𝐴 : Set 𝑨} (x : 𝐴) : 𝕃 𝐴 → Set 𝑨

data 𝕃 {𝑨} (𝐴 : Set 𝑨) where
  ∅ : 𝕃 𝐴
  ∷ : {x₀ : 𝐴} → {x₁s : 𝕃 𝐴} → x₀ ∉ x₁s → 𝕃 𝐴

data _∉_ {𝑨} {𝐴 : Set 𝑨} (𝔞 : 𝐴) where
  ∉∅ : 𝔞 ∉ ∅
  ∉∷ : ∀ {x₀} → 𝔞 ≢ x₀ → ∀ {x₁s} → 𝔞 ∉ x₁s → (x₀∉x₁s : x₀ ∉ x₁s) → 𝔞 ∉ (∷ x₀∉x₁s)

𝕃→𝑳 : ∀ {𝑨} {𝐴 : Set 𝑨} → 𝕃 𝐴 → 𝑳 𝐴
𝕃→𝑳 ∅ = ∅
𝕃→𝑳 (∷ {x} ∉∅) = x ∷ₗ ∅
𝕃→𝑳 (∷ {x₀} (∉∷ {x₁} x {x₂s} x3 x4)) = x₀ ∷ₗ x₁ ∷ₗ 𝕃→𝑳 x₂s

data _∈_ {𝑨} {𝐴 : Set 𝑨} (𝔞 : 𝐴) : 𝕃 𝐴 → Set 𝑨 where
  here : ∀ {x₀s} (𝔞∉x₀s : 𝔞 ∉ x₀s) → 𝔞 ∈ ∷ 𝔞∉x₀s
  there : ∀ {x₁s} → (𝔞∈x₁s : 𝔞 ∈ x₁s) → ∀ {x₀} → (x₀∉x₁s : x₀ ∉ x₁s)  → 𝔞 ∈ ∷ x₀∉x₁s

data _[_]=_ {𝑨} {𝐴 : Set 𝑨} : 𝕃 𝐴 → ℕ → 𝐴 → Set 𝑨 where
  here  : ∀ {𝔞 xs} (𝔞∉xs : 𝔞 ∉ xs) → ∷ 𝔞∉xs [ 0 ]= 𝔞
  there : ∀ {x₀ x₁s} (x₀∉x₁s : x₀ ∉ x₁s) {i 𝔞} (x₁s[i]=𝔞 : x₁s [ i ]= 𝔞) → ∷ x₀∉x₁s [ suc i ]= 𝔞

[]=-thm₀ : ∀ {𝑨} {𝐴 : Set 𝑨} {L : 𝕃 𝐴} {n} {a} → L [ n ]= a → a ∉ L → ⊥
[]=-thm₀ (here 𝔞∉xs) (∉∷ x x₁ .𝔞∉xs) = x refl
[]=-thm₀ (there x₀∉x₁s x) (∉∷ x₁ x₂ .x₀∉x₁s) = []=-thm₀ x x₂

data ∅⊂_ {𝑨} {𝐴 : Set 𝑨} : 𝕃 𝐴 → Set 𝑨 where
  ∅⊂∷ : ∀ {x₀ x₁s} → (x₀∉x₁s : x₀ ∉ x₁s) → ∅⊂ ∷ x₀∉x₁s

lastIndex : ∀ {𝑨} {𝐴 : Set 𝑨} {L : 𝕃 𝐴} (∅⊂L : ∅⊂ L) → ℕ
lastIndex (∅⊂∷ ∉∅) = 0
lastIndex (∅⊂∷ (∉∷ x x₀∉x₁s₁ x₀∉x₁s)) = suc (lastIndex (∅⊂∷ x₀∉x₁s))

length : ∀ {𝑨} {𝐴 : Set 𝑨} → 𝕃 𝐴 → ℕ
length ∅ = 0
length (∷ {x₁s = x₁s} _) = suc (length x₁s)

sym' : ∀ {𝑨} {𝐴 : Set 𝑨} {x y : 𝐴} → x ≢ y → y ≢ x
sym' x₁ x₂ = x₁ (sym x₂)

postulate
  T : Set
  ⋆a ⋆b ⋆c ⋆d : T
  a≢b : ⋆a ≢ ⋆b
  a≢c : ⋆a ≢ ⋆c
  a≢d : ⋆a ≢ ⋆d
  b≢c : ⋆b ≢ ⋆c
  b≢d : ⋆b ≢ ⋆d
  c≢d : ⋆c ≢ ⋆d

b≢a = sym' a≢b
c≢a = sym' a≢c
d≢a = sym' a≢d
c≢b = sym' b≢c
d≢b = sym' b≢d
d≢c = sym' c≢d

a∉∅ : ⋆a ∉ ∅
a∉∅ = ∉∅

a∉b   = ∉∷ a≢b ∉∅ ∉∅
c∉b   = ∉∷ c≢b ∉∅ ∉∅
d∉b   = ∉∷ d≢b ∉∅ ∉∅
a∉c   = ∉∷ a≢c ∉∅ ∉∅
b∉c   = ∉∷ b≢c ∉∅ ∉∅
c∉d   = ∉∷ c≢d ∉∅ ∉∅
b∉d   = ∉∷ b≢d ∉∅ ∉∅
a∉d   = ∉∷ a≢d ∉∅ ∉∅
b∉a   = ∉∷ b≢a ∉∅ ∉∅
c∉a   = ∉∷ c≢a ∉∅ ∉∅
d∉a   = ∉∷ d≢a ∉∅ ∉∅
a∉bc  = ∉∷ a≢b a∉c b∉c
a∉cd  = ∉∷ a≢c a∉d c∉d
b∉cd  = ∉∷ b≢c b∉d c∉d
c∉ab  = ∉∷ c≢a c∉b a∉b
d∉ab  = ∉∷ d≢a d∉b a∉b
c∉ba  = ∉∷ c≢b c∉a b∉a
d∉ba  = ∉∷ d≢b d∉a b∉a
a∉bcd = ∉∷ a≢b a∉cd b∉cd
d∉cab = ∉∷ d≢c d∉ab c∉ab
d∉cba = ∉∷ d≢c d∉ba c∉ba

[a] = ∷ a∉∅
[ab] = ∷ a∉b
[ba] = ∷ b∉a
[abc] = ∷ a∉bc
[cab] = ∷ c∉ab
[cba] = ∷ c∉ba
[abcd] = ∷ a∉bcd
[dcab] = ∷ d∉cab
[dcba] = ∷ d∉cba

last : ∀ {𝑨} {𝐴 : Set 𝑨} {L} → ∅⊂ L → 𝐴
last (∅⊂∷ {x₀} {∅} _) = x₀
last (∅⊂∷ {x₁s = ∷ x₁∉x₂s} _) = last (∅⊂∷ x₁∉x₂s)

last-thm₁ : ∀ {𝑨} {𝐴 : Set 𝑨} {L : 𝕃 𝐴} → (∅⊂L : ∅⊂ L) → L [ lastIndex ∅⊂L ]= last ∅⊂L
last-thm₁ (∅⊂∷ ∉∅) = here ∉∅
last-thm₁ (∅⊂∷ (∉∷ x x₀∉x₁s₁ x₀∉x₁s)) = there (∉∷ x x₀∉x₁s₁ x₀∉x₁s) (last-thm₁ (∅⊂∷ x₀∉x₁s))

mutual
  init : ∀ {𝑨} {𝐴 : Set 𝑨} {x₀s : 𝕃 𝐴} (∅⊂x₀s : ∅⊂ x₀s) → 𝕃 𝐴
  init (∅⊂∷ ∉∅) = ∅
  init (∅⊂∷ (∉∷ _ x₀∉x₂s x₁∉x₂s)) = ∷ (init∉ (∅⊂∷ _) (∉∷ _ x₀∉x₂s x₁∉x₂s))

  init∉ : ∀ {𝑨} {𝐴 : Set 𝑨} {x₀ : 𝐴} {x₁s : 𝕃 𝐴} (∅⊂x₁s : ∅⊂ x₁s) → x₀ ∉ x₁s → x₀ ∉ init ∅⊂x₁s
  init∉ () ∉∅
  init∉ (∅⊂∷ _) (∉∷ _ ∉∅ ∉∅) = ∉∅
  init∉ (∅⊂∷ _) (∉∷ x₀≢x₁ (∉∷ x₀≢x₂ x₀∉x₃s x₂∉x₃s) (∉∷ x₁≢x₂ x₁∉x₃s .x₂∉x₃s)) = ∉∷ x₀≢x₁ (init∉ _ (∉∷ x₀≢x₂ x₀∉x₃s x₂∉x₃s)) (init∉ _ (∉∷ x₁≢x₂ x₁∉x₃s x₂∉x₃s))

open import Tactic.Reflection.Reright

module _ where
  open import Agda.Builtin.Reflection

  shiftRight : ∀ {𝑨} {𝐴 : Set 𝑨} {xs : 𝕃 𝐴} (∅⊂xs : ∅⊂ xs) → last ∅⊂xs ∉ init ∅⊂xs
  shiftRight (∅⊂∷ ∉∅) = ∉∅
  shiftRight (∅⊂∷ {x₀} (∉∷ {x₁} x₀≢x₁ {x₂s} x₀∉x₂s x₁∉x₂s)) =
    let xₙ≢x₀ = let x₁s[last]=lastx₁s = last-thm₁ (∅⊂∷ x₁∉x₂s) in
                    λ lastx₁s≡x₀ →
                        let x₁s[last]=x₀ : ∷ x₁∉x₂s [ lastIndex (∅⊂∷ x₁∉x₂s) ]= x₀
                            x₁s[last]=x₀ = --subst (∷ x₁∉x₂s [ lastIndex (∅⊂∷ x₁∉x₂s) ]=_) lastx₁s≡x₀ x₁s[last]=lastx₁s
                                           reright lastx₁s≡x₀ {!x₁s[last]=lastx₁s!} -- reright doesn't rewrite x₁s[last]=lastx₁s
                                           --{!!}
                        in []=-thm₀ x₁s[last]=x₀ (∉∷ x₀≢x₁ x₀∉x₂s x₁∉x₂s)
    in
      ∉∷ (eraseNegation xₙ≢x₀)
         (shiftRight (∅⊂∷ x₁∉x₂s))
         (init∉ (∅⊂∷ x₁∉x₂s) (∉∷ x₀≢x₁ x₀∉x₂s x₁∉x₂s))
