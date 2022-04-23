let Prelude =
      https://prelude.dhall-lang.org/v19.0.0/package.dhall sha256:eb693342eb769f782174157eba9b5924cf8ac6793897fc36a31ccbd6f56dafe2
let
  InterfaceConfig : Type = {
      name : Text
    , description : Text
    , native_vlan : Text
  }
let mkInterfaces = λ(interfaces: List InterfaceConfig) ->
  Prelude.List.map 
    { index: Natural, value: InterfaceConfig }
    (Prelude.Map.Entry Natural InterfaceConfig)
    (λ(item: { index: Natural, value: InterfaceConfig }) -> { mapKey = (item.index + 1), mapValue = item.value })
    (List/indexed InterfaceConfig interfaces)
let mkRoute = λ(dst: Text) -> λ(gw: Text) -> { ip_dst = dst, ip_gw = gw }
in
{
  -- include = [ "acls.yaml" ],
  vlans = {
    dmz = {
      vid = 100,
      description = "Zone démilitarisée",
      faucet_mac = "0e:00:00:00:10:01",
      routes = [ (mkRoute "10.0.0.0/24" "10.0.0.1") ]
    },
  },

  routers = {
    router01 = { vlans = [ "dmz" ] }
  },

  dps = {
    sw1 = { 
      dp_id = 0x1,
      hardware = "Open vSwitch",
      interfaces = (mkInterfaces [
        { name = "h1", description = "host1", native_vlan = "dmz" },
        { name = "h2", description = "host2", native_vlan = "dmz" },
      ])
    }
  }
}
