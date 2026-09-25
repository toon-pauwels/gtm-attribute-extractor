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

scenarios: []


___NOTES___

Created on 25/09/2026, 13:00:55


