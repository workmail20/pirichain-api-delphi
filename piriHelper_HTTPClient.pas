unit piriHelper_HTTPClient;

interface

uses classes, System.Net.HttpClient, sysutils, System.Net.HTTPClientComponent,
  System.JSON, StrUtils, System.Net.URLClient, System.NetConsts;

Type
  TPiri_HTTP = class
  public
    function sendPOST_json(url: string; data: string): string;
    function createNewAddress(language: string; commercial: boolean): string;
    function rescuePrivateKey(words: string;
      language: string = 'english'): string;
    function getMnemonic(privateKey: string;
      language: string = 'english'): string;
    function getBalance(address: string; assetID: string): string;
    function getBalanceList(address: string): string;
    function getToken(assetID: string): string;
    function listTokens(skip: string = '0'; limit: string = '10'): string;
    function sendToken(address: string; privateKey: string; _to: string;
      amount: string; assetID: string): string;
    function createToken(creatorAddress: string; privateKey: string;
      tokenName: string; tokenSymbol: string; totalSupply: string; logo: string;
      decimals: string; description: string; webSite: string;
      socialMediaFacebookURL: string; socialMediaTwitterURL: string;
      socialMediaMediumURL: string; socialMediaYoutubeURL: string;
      socialMediaRedditURL: string; socialMediaBitcoinTalkURL: string;
      socialMediaInstagramURL: string; mailAddress: string;
      companyAddress: string; sector: string; hasAirdrop: boolean;
      hasStake: boolean): string;
    function getScenario(address: string): string;
    function createScenario(address: string; privateKey: string;
      scenarioText: string; name: string; description: string;
      tags: string): string;
    function listMyScenarios(ownerAddress: string): string;
    function listScenarios(skip: string = '0'; limit: string = '10'): string;
    function executeScenario(scenarioAddress: string; address: string;
      privateKey: string; method: string; params: string): string;
    function previewScenario(scenarioText: string; address: string;
      privateKey: string; method: string; params: string): string;
    function listTransactions(skip: string = '0'; limit: string = '10'): string;
    function listPoolTransactions(): string;
    function listTransactionsByAssetID(assetID: string = '-1';
      skip: string = '0'; limit: string = '10'): string;
    function listTransactionsByAddr(address: string; skip: string = '0';
      limit: string = '10'): string;
    function getTransaction(tx: string): string;
    function getPoolTransaction(tx: string): string;
    function getDetailsOfAddress(address: string): string;
    function getBlocks(skip: string = '0'; limit: string = '10'): string;
    function getBlocksDesc(skip: string = '0'; limit: string = '10'): string;
    function getLastBlocks(limit: string = '10'): string;
    function getOnlyBlocks(skip: string = '0'; limit: string = '10'): string;
    function getBlock(blockNumber: string): string;
    function decrypt(customID: string; privateKey: string;
      receiptPub: string): string;
    function pushData(address: string; privateKey: string; _to: string;
      customData: string; inPubKey: string): string;

    function pushDataList(address: string; privateKey: string; _to: string;
      customData: string): string;
    function listData(skip: string = '0'; limit: string = '10'): string;
    function listDataByAddress(address: string; skip: string = '0';
      limit: string = '10'): string;
    function getAddressListByAsset(assetID: string = '-1'; start: string = '0';
      limit: string = '10'): string;
    function isValidAddress(address: string): string;
    function search(value: string): string;
    function listMyDelegation(delegationAddress: string;
      delegationPrivateKey: string): string;
    function unFreezeCoin(delegationAddress: string;
      delegationPrivateKey: string; nodeAddress: string;
      txHash: string): string;
    function freezeCoin(delegationAddress: string; delegationPrivateKey: string;
      duptyAddress: string; amount: string): string;
    function joinAsDeputy(address: string; privateKey: string;
      alias: string): string;
    function checkDeputy(address: string): string;
    function listDeputies(): string;
    function getMyRewardQuantity(base58: string; privateKey: string): string;
    function createAddressForBuyPiri(_type: string): string;
    function getBalanceForBuyPiri(_type: string; address: string;
      piriAddress: string): string;
    function getPiriPrice(_type: string = 'busd'): string;
    function getRichList(assetID: string = '-1'; skip: string = '0';
      limit: string = '10'): string;
    function getDetailStats(assetID: string = '-1'): string;
    function getStats(): string;
    function listDelegationTopN(): string;
    function getCirculation(): string;

    Constructor Create(main: boolean); overload;
    destructor Destroy; override;
  private const
    mainEndpoit = 'https://core.pirichain.com/';
    testEndpoit = 'https://testnet.pirichain.com/';

  var
    endpoint: string;
    HttpClient: THttpClient;
  end;

implementation

destructor TPiri_HTTP.Destroy;
begin
  if (HttpClient <> nil) then
    HttpClient.Free;
  inherited;
end;

constructor TPiri_HTTP.Create(main: boolean);
var
  exc: Exception;
begin
  if (main) then
  begin
    endpoint := mainEndpoit;
  end
  else
  begin
    endpoint := testEndpoit;
  end;

  HttpClient := THttpClient.Create();
  try
    HttpClient.ConnectionTimeout := 60000;
    HttpClient.ResponseTimeout := 60000;
    HttpClient.SendTimeout := 60000;

    HttpClient.ContentType := 'application/json';
    HttpClient.AcceptEncoding := 'UTF-8';
    HttpClient.UserAgent :=
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36 Edg/93.0.961.47';

  except
    if (HttpClient <> nil) then
      HttpClient.Free;

    exc := Exception.Create('Abnormal');
    raise exc;
  end;
end;

function TPiri_HTTP.sendPOST_json(url: string; data: string): string;
var
  ReqJson: TStringStream;
begin
  result := '';

  ReqJson := TStringStream.Create(data, TEncoding.UTF8);
  try
    result := HttpClient.Post(url, ReqJson).ContentAsString(TEncoding.UTF8);
  finally
    if (ReqJson <> nil) then
      ReqJson.Free;
  end;
end;

function TPiri_HTTP.createNewAddress(language: string;
  commercial: boolean): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin
  result := '';

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('language', language);
    if (length(language) < 1) then
      JSONData.AddPair('english', language);

    JSONData.AddPair('commercial', IfThen(commercial, 'true', 'false'));

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'createNewAddress', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.rescuePrivateKey(words: string;
  language: string = 'english'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(words) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('language', language);
    if (length(language) < 1) then
      JSONData.AddPair('english', language);

    JSONData.AddPair('words', words);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'rescuePrivateKey', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getMnemonic(privateKey: string;
  language: string = 'english'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(privateKey) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('language', language);
    if (length(language) < 1) then
      JSONData.AddPair('english', language);

    JSONData.AddPair('privateKey', privateKey);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getMnemonic', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getBalance(address: string; assetID: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(address) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('assetID', assetID);
    if (length(assetID) < 1) then
      JSONData.AddPair('assetID', '-1');

    JSONData.AddPair('address', address);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getBalance', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getBalanceList(address: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(address) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('address', address);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getBalanceList', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getToken(assetID: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin
  result := '';

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('assetID', assetID);
    if (length(assetID) < 1) then
      JSONData.AddPair('assetID', '-1');

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getToken', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.listTokens(skip: string = '0';
  limit: string = '10'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin
  JSONData := TJSONObject.Create();

  try
    JSONData.AddPair('skip', skip);
    JSONData.AddPair('limit', limit);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'listTokens', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.sendToken(address: string; privateKey: string; _to: string;
  amount: string; assetID: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if ((length(address) < 8) or (length(privateKey) < 8) or (length(_to) < 8))
  then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('address', address);
    JSONData.AddPair('privateKey', privateKey);
    JSONData.AddPair('to', _to);
    JSONData.AddPair('amount', amount);
    JSONData.AddPair('assetID', assetID);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'sendToken', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.createToken(creatorAddress: string; privateKey: string;
  tokenName: string; tokenSymbol: string; totalSupply: string; logo: string;
  decimals: string; description: string; webSite: string;
  socialMediaFacebookURL: string; socialMediaTwitterURL: string;
  socialMediaMediumURL: string; socialMediaYoutubeURL: string;
  socialMediaRedditURL: string; socialMediaBitcoinTalkURL: string;
  socialMediaInstagramURL: string; mailAddress: string; companyAddress: string;
  sector: string; hasAirdrop: boolean; hasStake: boolean): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('creatorAddress', creatorAddress);
    JSONData.AddPair('privateKey', privateKey);
    JSONData.AddPair('tokenName', tokenName);
    JSONData.AddPair('tokenSymbol', tokenSymbol);
    JSONData.AddPair('totalSupply', totalSupply);
    JSONData.AddPair('logo', logo);
    JSONData.AddPair('decimals', decimals);
    JSONData.AddPair('description', description);
    JSONData.AddPair('webSite', webSite);
    JSONData.AddPair('socialMediaFacebookURL', socialMediaFacebookURL);
    JSONData.AddPair('socialMediaTwitterURL', socialMediaTwitterURL);
    JSONData.AddPair('socialMediaMediumURL', socialMediaMediumURL);
    JSONData.AddPair('socialMediaYoutubeURL', socialMediaYoutubeURL);
    JSONData.AddPair('socialMediaRedditURL', socialMediaRedditURL);
    JSONData.AddPair('socialMediaBitcoinTalkURL', socialMediaBitcoinTalkURL);
    JSONData.AddPair('socialMediaInstagramURL', socialMediaInstagramURL);
    JSONData.AddPair('mailAddress', mailAddress);
    JSONData.AddPair('companyAddress', companyAddress);
    JSONData.AddPair('sector', sector);
    JSONData.AddPair('hasAirdrop', IfThen(hasAirdrop, 'true', 'false'));
    JSONData.AddPair('hasStake', IfThen(hasStake, 'true', 'false'));

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'createToken', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getScenario(address: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(address) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();

  try
    JSONData.AddPair('address', address);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getScenario', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.createScenario(address: string; privateKey: string;
  scenarioText: string; name: string; description: string;
  tags: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(address) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();

  try
    JSONData.AddPair('address', address);
    JSONData.AddPair('privateKey', privateKey);
    JSONData.AddPair('scenarioText', scenarioText);
    JSONData.AddPair('name', name);
    JSONData.AddPair('description', description);
    JSONData.AddPair('tags', tags);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'createScenario', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.listMyScenarios(ownerAddress: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(ownerAddress) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('ownerAddress', ownerAddress);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'listMyScenarios', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.listScenarios(skip: string = '0';
  limit: string = '10'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('skip', skip);
    JSONData.AddPair('limit', limit);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'listScenarios', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.executeScenario(scenarioAddress: string; address: string;
  privateKey: string; method: string; params: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('scenarioAddress', scenarioAddress);
    JSONData.AddPair('address', address);
    JSONData.AddPair('privateKey', privateKey);
    JSONData.AddPair('method', method);
    JSONData.AddPair('params', params);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'executeScenario', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.previewScenario(scenarioText: string; address: string;
  privateKey: string; method: string; params: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  // $params = ["Data1", "Data2"]

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('scenarioText', scenarioText);
    JSONData.AddPair('address', address);
    JSONData.AddPair('privateKey', privateKey);
    JSONData.AddPair('method', method);
    JSONData.AddPair('params', params);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'previewScenario', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.listTransactions(skip: string = '0';
  limit: string = '10'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('skip', skip);

    JSONData.AddPair('limit', limit);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'listTransactions', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.listPoolTransactions(): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'listPoolTransactions', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.listTransactionsByAssetID(assetID: string = '-1';
  skip: string = '0'; limit: string = '10'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('limit', limit);

    JSONData.AddPair('skip', skip);
    JSONData.AddPair('assetID', assetID);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'listTransactionsByAssetID', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.listTransactionsByAddr(address: string; skip: string = '0';
  limit: string = '10'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('address', address);
    JSONData.AddPair('limit', limit);

    JSONData.AddPair('skip', skip);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'listTransactionsByAddr', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getTransaction(tx: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(tx) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('tx', tx);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getTransaction', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getPoolTransaction(tx: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(tx) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('tx', tx);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getPoolTransaction', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getDetailsOfAddress(address: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(address) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('address', address);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getDetailsOfAddress', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getBlocks(skip: string = '0'; limit: string = '10'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('skip', skip);

    JSONData.AddPair('limit', limit);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getBlocks', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getBlocksDesc(skip: string = '0';
  limit: string = '10'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('skip', skip);

    JSONData.AddPair('limit', limit);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getBlocksDesc', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getLastBlocks(limit: string = '10'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('limit', limit);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getLastBlocks', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getOnlyBlocks(skip: string = '0';
  limit: string = '10'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('skip', skip);

    JSONData.AddPair('limit', limit);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getOnlyBlocks', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getBlock(blockNumber: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(blockNumber) < 1) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('blockNumber', blockNumber);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getBlock', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.decrypt(customID: string; privateKey: string;
  receiptPub: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('customID', customID);
    JSONData.AddPair('privateKey', privateKey);
    JSONData.AddPair('receiptPub', receiptPub);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'decrypt', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.pushData(address: string; privateKey: string; _to: string;
  customData: string; inPubKey: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(address) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('address', address);
    JSONData.AddPair('privateKey', privateKey);
    JSONData.AddPair('to', _to);
    JSONData.AddPair('customData', customData);
    JSONData.AddPair('inPubKey', inPubKey);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'pushData', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.pushDataList(address: string; privateKey: string;
  _to: string; customData: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(address) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('address', address);
    JSONData.AddPair('privateKey', privateKey);
    JSONData.AddPair('to', _to);
    JSONData.AddPair('customData', customData);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'pushData', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.listData(skip: string = '0'; limit: string = '10'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('skip', skip);

    JSONData.AddPair('limit', limit);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'listData', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.listDataByAddress(address: string; skip: string = '0';
  limit: string = '10'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(address) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('address', address);
    JSONData.AddPair('skip', skip);
    JSONData.AddPair('limit', limit);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'listDataByAddress', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getAddressListByAsset(assetID: string = '-1';
  start: string = '0'; limit: string = '10'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('assetID', assetID);

    JSONData.AddPair('start', start);

    JSONData.AddPair('limit', limit);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getAddressListByAsset', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.isValidAddress(address: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(address) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('address', address);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'isValidAddress', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.search(value: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(value) < 1) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('value', value);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'search', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.listMyDelegation(delegationAddress: string;
  delegationPrivateKey: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('delegationAddress', delegationAddress);
    JSONData.AddPair('delegationPrivateKey', delegationPrivateKey);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'listMyDelegation', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.unFreezeCoin(delegationAddress: string;
  delegationPrivateKey: string; nodeAddress: string; txHash: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('delegationAddress', delegationAddress);
    JSONData.AddPair('delegationPrivateKey', delegationPrivateKey);
    JSONData.AddPair('nodeAddress', nodeAddress);

    JSONData.AddPair('txHash', txHash);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'unFreezeCoin', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.freezeCoin(delegationAddress: string;
  delegationPrivateKey: string; duptyAddress: string; amount: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('delegationAddress', delegationAddress);
    JSONData.AddPair('delegationPrivateKey', delegationPrivateKey);
    JSONData.AddPair('duptyAddress', duptyAddress);

    JSONData.AddPair('amount', amount);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'freezeCoin', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.joinAsDeputy(address: string; privateKey: string;
  alias: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('address', address);

    JSONData.AddPair('privateKey', privateKey);

    JSONData.AddPair('alias', alias);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'joinAsDeputy', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.checkDeputy(address: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(address) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('address', address);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'checkDeputy', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.listDeputies(): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'listDeputies', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getMyRewardQuantity(base58: string;
  privateKey: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
  exc: Exception;
begin
  result := '';
  if (length(base58) < 8) then
  begin
    exc := Exception.Create('Abnormal');
    raise exc;
  end;

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('base58', base58);

    JSONData.AddPair('privateKey', privateKey);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getMyRewardQuantity', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.createAddressForBuyPiri(_type: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('type', _type);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'createAddressForBuyPiri', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getBalanceForBuyPiri(_type: string; address: string;
  piriAddress: string): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('type', _type);
    JSONData.AddPair('address', address);

    JSONData.AddPair('piriAddress', piriAddress);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getBalanceForBuyPiri', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getPiriPrice(_type: string = 'busd'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('type', _type);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getPiriPrice', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getRichList(assetID: string = '-1'; skip: string = '0';
  limit: string = '10'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('assetID', assetID);
    JSONData.AddPair('skip', skip);
    JSONData.AddPair('limit', limit);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getRichList', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getDetailStats(assetID: string = '-1'): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONData.AddPair('assetID', assetID);

    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getDetailStats', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getStats(): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getStats', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.listDelegationTopN(): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    result := sendPOST_json(endpoint + 'listDelegationTopN', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

function TPiri_HTTP.getCirculation(): string;
var
  JSONData: TJSONObject;
  JSONstring: string;
begin

  JSONData := TJSONObject.Create();
  try
    JSONstring := JSONData.ToString();
    result := sendPOST_json(endpoint + 'getCirculation', JSONstring);
  finally
    if (JSONData <> nil) then
      JSONData.Free;
  end;
end;

end.
