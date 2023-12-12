{ lib, macvlan-name }:

{ container_name
, image
, user ? null
, volumes ? [ ]
, environment ? [ ]
, ip ? null
, ports ? [ ]
, dependsOn ? [ ]
, extraOptions ? [ ]
}:
let
  addIfExists = opts: lib.attrsets.foldlAttrs (cum: key: value: cum // lib.attrsets.optionalAttrs (value != null && value != [ ]) { "${key}" = value; }) { } opts;
in
{
  "${container_name}" = {
    autoStart = true;
    extraOptions = extraOptions ++ lib.lists.optional (ip != null) [
      "--network=${macvlan-name}"
      "--ip=${ip}"
    ];
  } // addIfExists {
    inherit image user volumes environment ip ports dependsOn;
  };
}
