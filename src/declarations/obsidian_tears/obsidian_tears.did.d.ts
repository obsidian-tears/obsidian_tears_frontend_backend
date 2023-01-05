import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AccountIdentifier = string;
export type ApiError = { 'Limit' : null } |
  { 'Unauthorized' : null } |
  { 'Other' : string };
export type ApiResponse = { 'Ok' : Array<TokenIndex> } |
  { 'Err' : ApiError };
export type ApiResponse_1 = { 'Ok' : string } |
  { 'Err' : ApiError };
export type ApiResponse_2 = { 'Ok' : RewardInfo } |
  { 'Err' : ApiError };
export type ApiResponse_3 = { 'Ok' : null } |
  { 'Err' : ApiError };
export type ApiResponse_4 = { 'Ok' : Array<number> } |
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
  'buyItem' : ActorMethod<[TokenIndex, number, number], ApiResponse_4>,
  'checkIn' : ActorMethod<[], undefined>,
  'defeatMonster' : ActorMethod<[TokenIndex, number], ApiResponse_2>,
  'equipItems' : ActorMethod<[TokenIndex, Array<number>], ApiResponse_3>,
  'getEquippedItems' : ActorMethod<
    [TokenIndex, AccountIdentifier],
    Array<TokenIndex>,
  >,
  'getItemRegistryCopy' : ActorMethod<
    [],
    Array<[TokenIndex, AccountIdentifier]>,
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
  'itemIds' : Array<number>,
}
export type TokenIndex = number;
export interface _SERVICE extends ObsidianTearsRpg {}
