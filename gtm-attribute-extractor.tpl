___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Click Element Extractor",
  "description": "Retrieves a value from the clicked element or its closest ancestor, by searching for a matching attribute name or tag name.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "RADIO",
    "name": "searchMode",
    "displayName": "Search mode",
    "radioItems": [
      {
        "value": "attribute",
        "displayValue": "By attribute"
      },
      {
        "value": "tagName",
        "displayValue": "By tag name"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "attribute"
  },
  {
    "type": "TEXT",
    "name": "attributeName",
    "displayName": "Attribute Name",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "searchMode",
        "paramValue": "attribute",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "differentReturnAttr",
    "checkboxText": "Get value of a different attribute",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "searchMode",
        "paramValue": "attribute",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "returnAttributeName",
    "displayName": "Return attribute name",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "differentReturnAttr",
        "paramValue": true,
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "replaceUnderscores",
    "checkboxText": "Replace underscores with spaces",
    "simpleValueType": true,
    "defaultValue": false,
    "enablingConditions": [
      {
        "paramName": "searchMode",
        "paramValue": "attribute",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "tagName",
    "displayName": "Tag name",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "searchMode",
        "paramValue": "tagName",
        "type": "EQUALS"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

var copyFromDataLayer = require('copyFromDataLayer');

function formatValue(val) {
  return data.replaceUnderscores ? val.split('_').join(' ') : val;
}

function getPathSuffix(attr) {
  if (attr.indexOf('data-') === 0) {
    var parts = attr.substring(5).split('-');
    var camel = parts.map(function(part, index) {
      if (index === 0) return part;
      return part.charAt(0).toUpperCase() + part.substring(1);
    }).join('');
    return '.dataset.' + camel;
  } else {
    return '.attributes.' + attr + '.value';
  }
}

function searchByTagName() {
  var path = 'gtm.element';
  var targetTag = data.tagName.toUpperCase();
  while (copyFromDataLayer(path + '.tagName')) {
    var tag = copyFromDataLayer(path + '.tagName');
    if (tag.toUpperCase() === targetTag) {
      var innerText = copyFromDataLayer(path + '.innerText');
      return innerText ? formatValue(innerText.trim()) : undefined;
    }
    path = path + '.parentElement';
  }
  return undefined;
}

function searchByAttribute() {
  var path = 'gtm.element';
  var searchSuffix = getPathSuffix(data.attributeName);
  var returnAttr = data.differentReturnAttr ? data.returnAttributeName : data.attributeName;
  var returnSuffix = getPathSuffix(returnAttr);
  while (copyFromDataLayer(path + '.tagName')) {
    var searchVal = copyFromDataLayer(path + searchSuffix);
    if (searchVal !== undefined) {
      var returnVal = copyFromDataLayer(path + returnSuffix);
      return returnVal !== undefined ? formatValue(returnVal) : undefined;
    }
    path = path + '.parentElement';
  }
  return undefined;
}

return data.searchMode === 'tagName' ? searchByTagName() : searchByAttribute();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedKeys",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "gtm.element.*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: data-* attribute found directly on element
  code: |-
    mock('copyFromDataLayer', function(key) {
      if (key === 'gtm.element.tagName') return 'BUTTON';
      if (key === 'gtm.element.dataset.trackingAction') return 'navigation';
      return undefined;
    });
    var result1 = runCode({ searchMode: 'attribute', attributeName: 'data-tracking-action', differentReturnAttr: false, replaceUnderscores: true });
    assertThat(result1).isEqualTo('navigation');
- name: data-* attribute with underscores replaced
  code: |-
    mock('copyFromDataLayer', function(key) {
      if (key === 'gtm.element.tagName') return 'BUTTON';
      if (key === 'gtm.element.dataset.trackingComponent') return 'park_and_train';
      return undefined;
    });
    var result2 = runCode({ searchMode: 'attribute', attributeName: 'data-tracking-component', differentReturnAttr: false, replaceUnderscores: true });
    assertThat(result2).isEqualTo('park and train');
- name: underscore replacement disabled
  code: |-
    mock('copyFromDataLayer', function(key) {
      if (key === 'gtm.element.tagName') return 'BUTTON';
      if (key === 'gtm.element.dataset.trackingComponent') return 'park_and_train';
      return undefined;
    });
    var result3 = runCode({ searchMode: 'attribute', attributeName: 'data-tracking-component', differentReturnAttr: false, replaceUnderscores: false });
    assertThat(result3).isEqualTo('park_and_train');
- name: attribute found on parent element
  code: |-
    mock('copyFromDataLayer', function(key) {
      if (key === 'gtm.element.tagName') return 'SPAN';
      if (key === 'gtm.element.dataset.trackingAction') return undefined;
      if (key === 'gtm.element.parentElement.tagName') return 'BUTTON';
      if (key === 'gtm.element.parentElement.dataset.trackingAction') return 'navigation';
      return undefined;
    });
    var result4 = runCode({ searchMode: 'attribute', attributeName: 'data-tracking-action', differentReturnAttr: false, replaceUnderscores: true });
    assertThat(result4).isEqualTo('navigation');
- name: attribute not found — returns undefined
  code: |-
    mock('copyFromDataLayer', function(key) {
      if (key === 'gtm.element.tagName') return 'SPAN';
      if (key === 'gtm.element.parentElement.tagName') return undefined;
      return undefined;
    });
    var result5 = runCode({ searchMode: 'attribute', attributeName: 'data-tracking-action', differentReturnAttr: false, replaceUnderscores: true });
    assertThat(result5).isUndefined();
- name: search one attribute, return a different one
  code: |-
    mock('copyFromDataLayer', function(key) {
      if (key === 'gtm.element.tagName') return 'A';
      if (key === 'gtm.element.dataset.trackingAction') return 'navigation';
      if (key === 'gtm.element.attributes.href.value') return 'https://example.com';
      return undefined;
    });
    var result6 = runCode({ searchMode: 'attribute', attributeName: 'data-tracking-action', differentReturnAttr: true, returnAttributeName: 'href', replaceUnderscores: false });
    assertThat(result6).isEqualTo('https://example.com');
- name: search by tag name — innerText returned
  code: |-
    mock('copyFromDataLayer', function(key) {
      if (key === 'gtm.element.tagName') return 'SPAN';
      if (key === 'gtm.element.parentElement.tagName') return 'BUTTON';
      if (key === 'gtm.element.parentElement.innerText') return 'Belgium';
      return undefined;
    });
    var result7 = runCode({ searchMode: 'tagName', tagName: 'button' });
    assertThat(result7).isEqualTo('Belgium');
- name: tag name not found — returns undefined
  code: |-
    mock('copyFromDataLayer', function(key) {
      if (key === 'gtm.element.tagName') return 'SPAN';
      if (key === 'gtm.element.parentElement.tagName') return undefined;
      return undefined;
    });
    var result8 = runCode({ searchMode: 'tagName', tagName: 'button' });
    assertThat(result8).isUndefined();
- name: standard (non-data) attribute
  code: |-
    mock('copyFromDataLayer', function(key) {
      if (key === 'gtm.element.tagName') return 'INPUT';
      if (key === 'gtm.element.attributes.value.value') return 'all locations';
      return undefined;
    });
    var result9 = runCode({ searchMode: 'attribute', attributeName: 'value', differentReturnAttr: false, replaceUnderscores: false });
    assertThat(result9).isEqualTo('all locations');


___NOTES___

Created on 25/09/2026, 13:10:08


