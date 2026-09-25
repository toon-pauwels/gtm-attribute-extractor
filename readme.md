# Data Attribute Extractor

A Google Tag Manager variable template that retrieves a value from the clicked element or its closest ancestor, by searching for a matching attribute name or tag name.

## Overview

When working with click triggers in GTM, the clicked element is not always the element that holds the data you need — it might be a child element like an icon or a `<span>` inside a button. This template walks up the DOM from the clicked element until it finds the element matching your search criteria, then returns the value you specify.

It replaces multiple Custom JavaScript variables with a single reusable template.

## Fields

### Search mode
Choose how to search for the target element:

| Option | Description |
|---|---|
| **By attribute name** | Walks up the DOM until it finds an element with the specified attribute |
| **By tag name** | Walks up the DOM until it finds an element with the specified HTML tag |

---

### By attribute name

**Attribute name** *(required)*
The attribute to search for on the clicked element or its ancestors.

Examples:
- `data-tracking-action`
- `data-name`
- `href`
- `id`
- `value`

Supports:
- `data-*` attributes — accessed via the `dataset` API (e.g. `data-tracking-action` → `dataset.trackingAction`)
- Standard attributes — accessed via `attributes.attrName.value` (e.g. `href`, `id`, `class`)

> **Note:** Hyphenated non-data attributes (e.g. `aria-label`) are not supported due to sandbox limitations.

**Get value of a different attribute** *(optional checkbox)*
When enabled, the template searches for the **Attribute name** above but returns the value of a different attribute on the same element.

**Return attribute name** *(visible when checkbox is ticked)*
The attribute whose value should be returned once the search attribute is found.

Example use case: search for `data-tracking-action` to identify the right element, but return its `href`.

---

### By tag name

**Tag name** *(required)*
The HTML tag to search for. The template walks up the DOM until it finds a matching tag and returns its `innerText`.

Example: `button`, `a`, `div`

---

### Replace underscores with spaces *(checkbox, default: on)*
When enabled, replaces all underscores (`_`) in the returned value with spaces. Useful when attribute values use underscores as word separators (e.g. `park_and_train` → `park and train`).

Only available when searching by attribute name.

## Usage examples

### Get a data attribute value
- Search mode: `By attribute name`
- Attribute name: `data-tracking-category`

### Get href from element with a specific data attribute
- Search mode: `By attribute name`
- Attribute name: `data-tracking-action`
- Get value of a different attribute: ✅
- Return attribute name: `href`

### Get button text when click may land on a child element
- Search mode: `By tag name`
- Tag name: `button`

## Permissions

This template requires **Reads from the data layer**, scoped to `gtm.element.*`.

## Notes

- The template checks the clicked element itself first before walking up to parent elements
- When no matching element is found, the template returns `undefined` — use GTM's built-in **Format Value** settings (Convert `undefined` to `n/a`, Change case, etc.) on the variable instance to handle this
- Regex is not supported in GTM's sandboxed JavaScript; underscore replacement uses `split('_').join(' ')` instead of `.replace()`

## Limitations

- Hyphenated non-`data-*` attributes (e.g. `aria-label`) are not supported
- Complex CSS selector queries (e.g. `closest('button.my-class')` or `querySelector('span')`) are not supported — use a Custom JavaScript variable for those cases
