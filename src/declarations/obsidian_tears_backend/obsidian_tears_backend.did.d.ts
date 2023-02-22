import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AccountIdentifier = string;
export type ApiError = { 'Limit' : null } |
  { 'Unauthorized' : null } |
  { 'Other' : string };
export type ApiResponse = { 'Ok' : Uint32Array } |
  { 'Err' : ApiError };
export type ApiResponse_1 = { 'Ok' : string } |
  { 'Err' : ApiError };
export type ApiResponse_2 = { 'Ok' : RewardInfo } |
  { 'Err' : ApiError };
export type ApiResponse_3 = { 'Ok' : null } |
  { 'Err' : ApiError };
export type HeaderField = [string, string];
export interface HttpRequest {
  'url' : string,
  'method' : string,
  'body' : Uint8Array,
  'headers' : Array<HeaderField>,
}
export interface HttpResponse {
  'body' : Uint8Array,
  'headers' : Array<HeaderField>,
  'streaming_strategy' : [] | [HttpStreamingStrategy],
  'status_code' : number,
}
export interface HttpStreamingCallbackResponse {
  'token' : [] | [HttpStreamingCallbackToken],
  'body' : Uint8Array,
}
export interface HttpStreamingCallbackToken {
  'key' : string,
  'sha256' : [] | [Uint8Array],
  'index' : bigint,
  'content_encoding' : string,
}
export type HttpStreamingStrategy = {
    'Callback' : {
      'token' : HttpStreamingCallbackToken,
      'callback' : [Principal, string],
    }
  };
export interface ObsidianTearsRpg {
  'acceptCycles' : ActorMethod<[], undefined>,
  'adminKillHeartbeat' : ActorMethod<[], undefined>,
  'adminStartHeartbeat' : ActorMethod<[], undefined>,
  'balance' : ActorMethod<[], bigint>,
  'buyItem' : ActorMethod<[TokenIndex, number, bigint, number], ApiResponse_3>,
  'checkIn' : ActorMethod<[], undefined>,
  'consumeItem' : ActorMethod<[TokenIndex, number], ApiResponse_3>,
  'defeatMonster' : ActorMethod<[TokenIndex, number], ApiResponse_2>,
  'equipItems' : ActorMethod<[TokenIndex, Uint16Array], ApiResponse_3>,
  'getEquippedItems' : ActorMethod<
    [TokenIndex, AccountIdentifier],
    Uint32Array
  >,
  'getItemRegistryCopy' : ActorMethod<
    [],
    Array<[TokenIndex, AccountIdentifier]>
  >,
  'http_request' : ActorMethod<[HttpRequest], HttpResponse>,
  'isHeartbeatRunning' : ActorMethod<[], boolean>,
  'loadGame' : ActorMethod<[TokenIndex], ApiResponse_1>,
  'openChest' : ActorMethod<[TokenIndex, number], ApiResponse_2>,
  'saveGame' : ActorMethod<[TokenIndex, string], ApiResponse_1>,
  'setMinter' : ActorMethod<[Principal], Result>,
  'verify' : ActorMethod<[], ApiResponse>,
}
export type Result = { 'ok' : null } |
  { 'err' : ApiError };
export interface RewardInfo {
  'xp' : number,
  'gold' : number,
  'itemIds' : Array<string>,
}
export type TokenIndex = number;
export interface _SERVICE extends ObsidianTearsRpg {}
