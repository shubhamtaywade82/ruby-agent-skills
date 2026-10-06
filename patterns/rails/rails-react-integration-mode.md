---
name: rails-react-integration-mode
description: "Choose and record one way for a Rails app to serve React: Inertia, JSON API with a separate client, or React islands."
family: rails
---

# Rails React Integration Mode

## Problem
A Rails application can serve React as Inertia pages, as a separate client over a JSON API, or as islands mounted in ERB/Hotwire pages. Each mode moves routing, authentication, authorization, and data loading to a different place; mixing them without a decision splits those conventions.

## Use when
Adding React to a Rails app, adding a second React surface, or when requests fail because two parts of the app assume different modes.

## Do not use when
The repository has already recorded its mode and the task stays inside it.

## Repository inspection
Inspect the `Gemfile` (`inertia_rails`, `vite_rails`, `jsbundling-rails`, `importmap-rails`), how React mounts today, API namespaces in `config/routes.rb`, and any architecture decision record.

## Implementation procedure
1. List the React surfaces and the controllers that feed them.
2. Choose the mode: Inertia when Rails should keep routing, sessions, and authorization and no public API is needed; JSON API when a separate client or third parties consume the data; islands when most pages stay server-rendered and only a few widgets need React.
3. Record the choice and its reason where the repository keeps decisions.
4. Keep authorization on the Rails side in every mode.

## Example

```ruby
# Three ways a Rails app can serve React. Pick one per application (or per
# clearly bounded area) and record it; mixing them silently splits auth,
# routing, and data-loading conventions.

# 1. Inertia (inertia_rails gem): Rails keeps routing, controllers, sessions,
#    and authorization; React replaces ERB views. No public JSON API.
class OrdersController < ApplicationController
  def index
    orders = policy_scope(Order).order(placed_at: :desc).limit(50)
    render inertia: "Orders/Index", props: {
      orders: orders.map { |order| order.as_json(only: %i[id status total_cents placed_at]) }
    }
  end
end

# 2. JSON API + separate React client: Rails is an API; the client owns
#    routing. Needs a versioned wire contract, CORS if cross-origin, and an
#    explicit browser-auth decision (session cookie + CSRF, or tokens).
module Api
  module V1
    class OrdersController < Api::BaseController
      def index
        orders = policy_scope(Order).order(placed_at: :desc, id: :desc).limit(50)
        render json: { data: orders.as_json(only: %i[id status total_cents placed_at]) }
      end
    end
  end
end

# 3. React islands inside Hotwire/ERB pages: Rails renders the page; one
#    widget mounts React with server-rendered, already-authorized props.
#    app/views/orders/show.html.erb:
#      <%= tag.div(data: { react_component: "OrderTimeline",
#                          props: @order.as_json(only: %i[id status]).to_json }) %>
```

## Failure modes
An Inertia page and a JSON endpoint both serving the same resource with different authorization, islands fetching their own data from an unauthenticated API, and a separate client added only to use a client-side router.

## Testing
Request tests per mode: Inertia component name and props, JSON status and keys, or the rendered mount point with its serialized props.

## Review checklist
Is the mode recorded, and does every React surface in this area use it?

## Related skills
rails-react-integration,rails-api-integration,rails-hotwire

Frontend side: react-agent-skills / react-architecture
