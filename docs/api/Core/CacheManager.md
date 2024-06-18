# CacheManager

`SUPPRESSWARNINGS`

Class used to manage caching using organization & session platform caches, as well as using a transaction cache


**Group** Core

## Methods
### `static getOrganizationCache()`

Returns the default organization-level cache instance, based on the `CacheConfiguration__mdt` record `CacheConfiguration.Organization`

#### Return

**Type**

Cacheable

**Description**

The singleton `Cacheable` instance for the default organization cache

### `static getOrganizationCache(CacheConfiguration__mdt configuration)`

Returns a organization-level cache instance, based on the provided `CacheConfiguration__mdt` record

#### Parameters

|Param|Description|
|---|---|
|`configuration`|An instance of `CacheConfiguration__mdt` to use to control the cache's behavior|

#### Return

**Type**

Cacheable

**Description**

The singleton `Cacheable` instance for the specified configuration record cache

### `static getSessionCache()`

Returns the default session-level cache instance,              based on the `CacheConfiguration__mdt` record `CacheConfiguration.Session`

#### Return

**Type**

Cacheable

**Description**

The singleton `Cacheable` instance for the default session cache

### `static getSessionCache(CacheConfiguration__mdt configuration)`

Returns a session-level cache instance,              based on the provided `CacheConfiguration__mdt` record

#### Parameters

|Param|Description|
|---|---|
|`configuration`|An instance of `CacheConfiguration__mdt` to use to control the cache's behavior|

#### Return

**Type**

Cacheable

**Description**

The singleton `Cacheable` instance for the specified configuration record cache

### `static getTransactionCache()`

Returns the default transaction-level cache instance, based on the `CacheConfiguration__mdt` record `CacheConfiguration.Transaction`

#### Return

**Type**

Cacheable

**Description**

The singleton `Cacheable` instance for the default transaction cache

---
## Interfaces
### Cacheable

Interface used to define the available methods used for
organization, session, and transaction caches

#### Methods
##### `contains(String key)`

Indicates if the cache contains a value for the specified key

###### Parameters

|Param|Description|
|---|---|
|`key`|The unique `String` key to look for in the cache|

###### Return

**Type**

Boolean

**Description**

Returns `true` if the cache contains the specified key

##### `contains(Set&lt;String&gt; keys)`

For the specified keys, a Map&lt;String, Boolean&gt; is returned that indicates if each of the specified keys is included in the cache

###### Parameters

|Param|Description|
|---|---|
|`keys`|The set of unique `String` keys to look for in the cache|

###### Return

**Type**

Map&lt;String,Boolean&gt;

**Description**

Returns an instance of `Map&lt;String, Boolean&gt;` containing each of the provided keys & if the key is contained in the cache

##### `containsAll(Set&lt;String&gt; keys)`

For the specified keys, indicates if all of the keys are included in the cache

###### Parameters

|Param|Description|
|---|---|
|`keys`|The set of unique `String` keys to look for in the cache|

###### Return

**Type**

Boolean

**Description**

Returns `true` if all of the provided keys are found in the cache. If 1 or more key is not found in the cache, this method returns `false`.

##### `get(String key)`

Returns the cached value for the specified key,              or `null` if the specified key is not present in the cache

###### Parameters

|Param|Description|
|---|---|
|`key`|The unique `String` key to look for in the cache|

###### Return

**Type**

Object

**Description**

Returns the `Object` cached value for the specified key

##### `get(String key, System cacheBuilderClass)`

Returns the cached value for the specified key,              or creates an instance ofthe specified `System.Type` to load the cache value

###### Parameters

|Param|Description|
|---|---|
|`key`|The unique `String` key to look for in the cache|
|`cacheBuilderClass`|The `System.Type` of the Apex class that handles loading the cache                           value for the specified key|

###### Return

**Type**

Object

**Description**

Returns the `Object` cached value for the specified key

##### `get(Set&lt;String&gt; keys)`

Returns all of the key-value pairs currently stored in the cache

###### Parameters

|Param|Description|
|---|---|
|`keys`|The set of unique `String` keys to look for in the cache|

###### Return

**Type**

Map&lt;String,Object&gt;

**Description**

Returns an instance of `Map&lt;String, Object&gt;` containing all of the specified keys, along with their cached values              (or null for any of the keys that have not been cached)

##### `getAll()`

Returns all of the key-value pairs currently stored in the cache

###### Return

**Type**

Map&lt;String,Object&gt;

**Description**

An instance of `Map&lt;String, Object&gt;` containing all of the cached keys & values in the cache

##### `getKeys()`

Returns all of the keys currently in the cache

###### Return

**Type**

Set&lt;String&gt;

**Description**

The instance of `Set&lt;String&gt;` containing all of the unique keys in the cache

##### `isAvailable()`

Indicates if the cache can be used in the current transaction

###### Return

**Type**

Boolean

**Description**

Returns `true` if the cache is available

##### `isEnabled()`

Indicates if the cache is currently enabled (controlled via the field `CacheConfiguration__mdt.IsEnabled__c`)

###### Return

**Type**

Boolean

**Description**

Returns `true` if the cache is enabled

##### `isImmutable()`

Indicates if the cache is currently immutable (controlled the field `CacheConfiguration__mdt.IsEnabled__c`) - when              the cache is immutable, any cached values cannot be changed until the cache expires

###### Return

**Type**

Boolean

**Description**

Returns `true` if the cache is immutable

##### `put(String key, Object value)`

Adds the specified value to the cache, using the provided key as a unique identifier

###### Parameters

|Param|Description|
|---|---|
|`key`|The unique `String` key to identify the value in the cache|
|`value`|The value to add to the cache|

##### `put(Map&lt;String,Object&gt; keyToValue)`

Provides a bulk way to add several keys & values to a cache

###### Parameters

|Param|Description|
|---|---|
|`keyToValue`|An instance of `Map&lt;String, Object&gt;` containing the                    key-value pairs to add to the cache|

##### `remove(String key)`

Removes any cached data from the cache for the provided key

###### Parameters

|Param|Description|
|---|---|
|`key`|The unique `String` key that identifies the value in the cache to remove|

##### `remove(Set&lt;String&gt; keys)`

Removes any cached data from the cache for the provided keys

###### Parameters

|Param|Description|
|---|---|
|`keys`|The set of unique `String` keys that identify the values in the cache to remove|

##### `removeAll()`

Removes all cached keys & values from the cache

---

