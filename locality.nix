let
   locality = "en_US.UTF-8";
in
{
  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n ={
    defaultLocale = "${locality}";
    extraLocaleSettings = {
      LC_ADDRESS = "${locality}";
      LC_IDENTIFICATION = "${locality}";
      LC_MEASUREMENT = "${locality}";
      LC_MONETARY = "${locality}";
      LC_NAME = "${locality}";
      LC_NUMERIC = "${locality}";
      LC_PAPER = "${locality}";
      LC_TELEPHONE = "${locality}";
      LC_TIME = "${locality}";
    };
  };
  #console.useXkbConfig = true;
  #services.xserver.xkb.layout = "en";
}