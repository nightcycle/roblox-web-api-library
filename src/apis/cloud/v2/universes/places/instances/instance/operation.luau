--!strict
-- Packages
local result = require("@pkg/@nightcycle/result")
local option = require("@pkg/@nightcycle/option")
local future = require("@pkg/@nightcycle/future")
local hashMap = require("@pkg/@nightcycle/hash-map")
local vec = require("@pkg/@nightcycle/vec")
local vecDeque = require("@pkg/@nightcycle/vec-deque")
local err = require("@pkg/@nightcycle/error")
local reqwest = require("@pkg/@nightcycle/reqwest")
-- Modules
local client = require("../../../../../../../client")
-- Constants
local CONSTANTS = require("../../../../../../../CONSTANTS")
-- Types
type Result<V, E> = result.Result<V, E>
type Option<V> = option.Option<V>
type Future<V> = future.Future<V>
type HashMap<K, V> = hashMap.HashMap<K, V>
type MutHashMap<K, V> = hashMap.MutHashMap<K, V>
type Vec<V> = vec.Vec<V>
type MutVec<V> = vec.MutVec<V>
type VecDeque<V> = vecDeque.VecDeque<V>
type Error<V, B> = err.Error<V, B>
type Response<B> = reqwest.Response<B>

export type RunContext = "Legacy" | "Server" | "Client" | "Plugin"
export type EngineInstanceDetails = {
	Folder: {},
} | {
	LocalScript: {
		Enabled: boolean,
		RunContext: RunContext,
		Source: string,
	},
} | {
	ModuleScript: {
		Source: string,
	},
} | {
	Script: {
		Enabled: boolean,
		RunContext: RunContext,
		Source: string,
	},
} | {}

export type PartialEngineInstanceDetails = {
	Folder: {},
} | {
	LocalScript: {
		Enabled: boolean?,
		RunContext: RunContext?,
		Source: string?,
	},
} | {
	ModuleScript: {
		Source: string?,
	},
} | {
	Script: {
		Enabled: boolean?,
		RunContext: RunContext?,
		Source: string?,
	},
} | {}

export type EngineInstance = {
	Details: EngineInstanceDetails,
	Id: string,
	Name: string,
	Parent: string,
}

export type CloudInstance = {
	engineInstance: EngineInstance,
	hasChildren: boolean,
	path: string,
}

export type Operation = {
	done: false,
	path: string,
} | {
	done: true,
	response: CloudInstance,
}

-- Constants
-- Private Functions
-- Class
local Util = {}

function Util.get(path: string): Future<Result<Operation, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:get(CONSTANTS.OPEN_CLOUD_BASE_URL .. `/cloud/v2/` .. path)
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(ok)
				return result.ok(ok:json():unwrap())
			end, function(e)
				return result.err(e)
			end)
	end)
end

return Util
