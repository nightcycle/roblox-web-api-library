--!strict
-- Packages
local result = require("@pkg/@nightcycle/result")
local option = require("@pkg/@nightcycle/option")
local future = require("@pkg/@nightcycle/future")
local err = require("@pkg/@nightcycle/error")
local reqwest = require("@pkg/@nightcycle/reqwest")

-- Modules
local client = require("../../../../../client")

-- Constants
local CONSTANTS = require("../../../../../CONSTANTS")

-- Types
type Result<V, E> = result.Result<V, E>
type Option<V> = option.Option<V>
type Future<V> = future.Future<V>
type Error<V, B> = err.Error<V, B>
type Response<B> = reqwest.Response<B>
type OkBody = {
	datastores: { { name: string, createdTime: string } },
	nextPageCursor: Option<string>,
}
-- Private Functions

-- Class
local Util = {}
Util.datastore = require("./datastore")

-- lists the datastores
function Util.get(
	universeId: number,
	cursor: Option<string>,
	limit: Option<number>,
	prefix: Option<string>
): Future<Result<OkBody, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:get(
				reqwest.Url.from(
					CONSTANTS.OPEN_CLOUD_BASE_URL
						.. `/datastores/v1/universes/{universeId}/standard-datastores`,
					{
						cursor = cursor:asNullable(),
						limit = limit:match(function(v): string?
							return tostring(v)
						end, function()
							return nil
						end),
						prefix = prefix:asNullable(),
					} :: any
				)
			)
			:build()
			:send()
			:await()
			:match(function(ok)
				local data = ok:json():unwrap()
				return result.ok({
					datastores = data["datastores"] :: any,
					nextPageCursor = if data["nextPageCursor"] and data["nextPageCursor"]:len() > 0
						then option.some(data["nextPageCursor"])
						else option.none(),
				})
			end, function(eResponse)
				return result.err(eResponse)
			end)
	end)
end

return Util
