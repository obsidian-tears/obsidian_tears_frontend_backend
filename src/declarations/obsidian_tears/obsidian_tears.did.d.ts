import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type ApiError = { 'Limit' : null } |
  { 'Unauthorized' : null } |
  { 'Other' : string };
export type ApiResponse = { 'Ok' : Array<TokenIndex> } |
  { 'Err' : ApiError };
export type ApiResponse_1 = { 'Ok' : null } |
  { 'Err' : ApiError };
export type ApiResponse_2 = { 'Ok' : Array<number> } |
  { 'Err' : ApiError };
export type ApiResponse_3 = { 'Ok' : string } |
  { 'Err' : ApiError };
export type HeaderField = [string, string];
export interface HttpRequest {
  'url' : string,
  'method' : string,
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
}
export interface HttpResponse {
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
  'streaming_strategy' : [] | [HttpStreamingStrategy],
  'status_code' : number,
}
export interface HttpStreamingCallbackResponse {
  'token' : [] | [HttpStreamingCallbackToken],
  'body' : Array<number>,
}
export interface HttpStreamingCallbackToken {
  'key' : string,
  'sha256' : [] | [Array<number>],
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
  'buyItem' : ActorMethod<[TokenIndex, Array<number>], ApiResponse_2>,
  'checkIn' : ActorMethod<[], undefined>,
  'defeatMonster' : ActorMethod<[TokenIndex, TokenIndex], ApiResponse_1>,
  'equipItems' : ActorMethod<[TokenIndex, Array<TokenIndex>], ApiResponse_1>,
  'getEquippedItems' : ActorMethod<[TokenIndex], Array<TokenIndex>>,
  'http_request' : ActorMethod<[HttpRequest], HttpResponse>,
  'isHeartbeatRunning' : ActorMethod<[], boolean>,
  'login' : ActorMethod<[TokenIndex], ApiResponse_3>,
  'openChest' : ActorMethod<[TokenIndex], ApiResponse_2>,
  'saveGame' : ActorMethod<[TokenIndex, string], ApiResponse_1>,
  'setMinter' : ActorMethod<[Principal], Result>,
  'verify' : ActorMethod<[], ApiResponse>,
}
export type Result = { 'ok' : null } |
  { 'err' : ApiError };
export type TokenIndex = number;
export interface _SERVICE extends ObsidianTearsRpg {}
