# Deep modules, seams, and dependency strategy

Reference for the `ruby-api-design` skill. Load it on demand when deciding what a module should hide, where its seam goes, how to test it through its dependencies, or when comparing alternative interfaces. The compatibility procedure and review checklist stay in the skill's `SKILL.md`.

## Vocabulary

Use these words consistently in design discussions and reviews:

- **Module**: anything with an interface and an implementation, at any scale: a method, class, gem, Rails engine, or a slice across layers.
- **Interface**: everything a caller must know to use the module correctly: the signature, plus invariants, ordering constraints, error modes, required configuration, and performance characteristics.
- **Implementation**: the code behind the interface.
- **Depth**: the behavior a caller or test can exercise per unit of interface it has to learn. Deep means a small interface over a lot of behavior; shallow means the interface is nearly as complex as the implementation.
- **Seam** (Michael Feathers): the place where behavior can be changed without editing that place; where the module's interface lives. Choosing the seam is a design decision separate from choosing what goes behind it.
- **Adapter**: a concrete implementation that fills a seam, such as a production HTTP client or an in-memory fake.
- **Leverage**: what callers gain from depth: more capability per thing learned, paid back across every call site and test.
- **Locality**: what maintainers gain from depth: changes, bugs, and verification concentrate in one place.

Depth is measured as leverage, not as the ratio of implementation lines to interface lines; that ratio rewards padding.

## Depth in Ruby

```ruby
# Shallow: the caller must know the steps and their order.
gateway = PaymentGateway.new(api_key: key)
token = gateway.tokenize(card)
intent = gateway.create_intent(amount_cents, token)
gateway.confirm(intent)

# Deep: one entry point hides the protocol, retries, and idempotency.
Payments.charge(order, card: card) # => Payments::Result (success? / failure_reason)
```

A deep module can be built from small internal parts with their own internal seams used by its own tests. Keep those internal seams out of the public interface.

Questions for any interface:

- Can it have fewer entry points?
- Can the arguments be simpler or fewer?
- Can more of the protocol, ordering, and error handling move inside?

## Dependency categories

Classify each dependency of the module; the category decides how it is tested across the seam.

1. **In-process**: pure computation and in-memory state. Merge freely and test through the interface directly. No adapter.
2. **Local stand-in available**: the Rails test database, the `:test` Active Job adapter, the Active Storage Disk service, Action Mailer's `:test` delivery method. Test with the stand-in running; the seam stays internal, with no port on the interface.
3. **Remote but owned**: another service or engine you run across a network or queue. Define a port at the seam, with a production adapter (HTTP, queue) and an in-memory adapter for tests, so the logic stays in one deep module.
4. **Truly external**: third-party APIs you do not control. Inject the client and give tests a fake or a stubbed HTTP layer (WebMock, VCR, or the repository's tool).

```ruby
# Category 3 or 4: a port with two real adapters.
class Shipping
  def initialize(carrier: Carriers::Http.new)
    @carrier = carrier
  end

  def dispatch(order)
    quote = @carrier.quote(order.parcel)
    @carrier.book(quote.id)
  end
end

module Carriers
  class InMemory
    attr_reader :bookings

    def initialize = @bookings = []
    def quote(parcel) = Quote.new(id: "q-#{parcel.weight_grams}")
    def book(quote_id) = @bookings << quote_id
  end
end
```

## Seam discipline

- **One adapter is a hypothetical seam; two is a real one.** A port with only a production implementation is indirection. Add it when a second adapter, usually the test one, exists.
- **Internal versus external seams.** Internal seams serve the module's own tests; do not widen the public interface to expose them.

## Testing: replace, don't layer

When shallow modules are merged into a deeper one:

- write tests at the new module's interface;
- delete the old unit tests on the removed shallow modules once the interface tests cover their behavior;
- assert observable outcomes through the interface, not internal state;
- a test that must change whenever the implementation changes is testing past the interface.

## Designing the interface twice

The first interface idea is rarely the best (John Ousterhout, "design it twice"). For a module whose interface matters:

1. Write down the constraints: callers, invariants, error modes, and each dependency's category.
2. Draft at least three substantially different interfaces, each under a different constraint:
   - the fewest entry points, one to three, each with maximum leverage;
   - the most flexible, supporting many use cases and extension;
   - the simplest possible common case;
   - a ports-and-adapters design, when dependencies cross a network.
   When the agent can run parallel sub-agents, give each one design brief; otherwise draft them one after another without revising earlier drafts.
3. For each, show the interface, a caller example, what it hides, its dependency strategy, and where leverage is high or thin.
4. Compare on depth, locality, and seam placement, then recommend one or a hybrid with reasons.
