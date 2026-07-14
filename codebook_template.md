# QNA Codebook — [Project Name]
Coder: _______________  Date: _______________  Corpus: _______________

## sub_type categories (actor classification)
Define BEFORE coding. Every subject/object must map to exactly one.

| sub_type | Definition | Example actors |
|---|---|---|
| labor | | |
| state | | |
| capital | | |
| _______ | | |

## verb_type categories (action classification)
Group raw verbs into a controlled vocabulary. One row per category.

| verb_type | Definition | Example verbs (lemma form) |
|---|---|---|
| collective_action | | strike, march, rally, protest |
| repression | | arrest, disperse, detain |
| demand | | demand, request |
| refusal | | refuse, reject, deny |
| negotiation | | negotiate, mediate |
| dismissal | | dismiss, fire, lay off |
| confrontation | | clash, fight, confront |
| _______ | | |

## Coding decisions log
Record every ambiguous case and how you resolved it. Future you (and your
co-coders) will need this.

| Date | Clause / example | Decision | Rationale |
|---|---|---|---|
| | | | |

## Inter-coder reliability
If more than one person is coding, have two people independently code the
same 10% sample, then compute agreement.

Target: Cohen's kappa >= 0.80 before full-scale coding.

    # In R:
    library(irr)
    kappa2(cbind(coder1_verb_type, coder2_verb_type))
