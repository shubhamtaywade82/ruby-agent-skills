---
name: rails-react-validation-error-mapping
description: "Map Rails 422 validation errors onto React form fields without losing any error."
family: rails
---

# Rails React Validation Error Mapping

## Problem
Rails returns validation failures as a 422 body keyed by attribute, while the form renders fields with its own names. Errors on `base`, nested attributes, or attributes the form does not show are easy to drop.

## Use when
A React form submits to a Rails endpoint that renders validation errors.

## Do not use when
The endpoint cannot fail validation (read-only or always-accepted input).

## Repository inspection
Inspect the Rails 422 body shape (see the `validation-error-contract` pattern), nested attribute naming, and the form library's error API.

## Implementation procedure
1. Confirm the Rails 422 body shape and recognize it with a guard.
2. Define an explicit attribute-to-field table.
3. Put `base` and unmapped attributes into a form-level error list.
4. Keep client-side validation as a usability aid only.

## Example

```ts
// Rails 422 body (see the validation-error-contract pattern):
// {"errors":[{"attribute":"quantity","type":"greater_than","message":"Quantity must be greater than 0"}]}
export type RailsValidationError = { attribute: string; type: string; message: string };
export type FormErrors<Field extends string> = {
  fields: Partial<Record<Field, string[]>>;
  base: string[]; // errors[:base] and attributes the form does not render
};

export function isRailsValidationBody(body: unknown): body is { errors: RailsValidationError[] } {
  if (typeof body !== "object" || body === null || !("errors" in body)) return false;
  const errors = (body as { errors: unknown }).errors;
  return Array.isArray(errors) && errors.every((error: unknown) =>
    typeof error === "object" && error !== null &&
    typeof (error as RailsValidationError).attribute === "string" &&
    typeof (error as RailsValidationError).message === "string");
}

// `attributeToField` is explicit: Rails attribute names (`shipping_address.zip`,
// `line_items[0].quantity`) are not assumed to equal form field names.
export function mapRailsErrors<Field extends string>(
  errors: RailsValidationError[],
  attributeToField: Readonly<Record<string, Field>>
): FormErrors<Field> {
  const result: FormErrors<Field> = { fields: {}, base: [] };
  for (const error of errors) {
    const field = attributeToField[error.attribute];
    if (field === undefined) {
      // Never drop an error the user cannot see: unmapped attributes go to base.
      result.base.push(error.message);
    } else {
      (result.fields[field] ??= []).push(error.message);
    }
  }
  return result;
}
```

## Failure modes
Dropping `base` or unmapped errors, assuming Rails attribute names equal field names, treating a CSRF 422 as a validation failure, and trusting client-side validation as authoritative.

## Testing
Mapped field errors, base and unmapped errors surfaced, a non-Rails body rejected, and an end-to-end or request test for one invalid submission.

## Review checklist
Can any Rails validation error fail to reach the user?

## Related skills
rails-react-integration,rails-validations

Frontend side: react-agent-skills / react-component-engineering
