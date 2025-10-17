{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.reticulum;
in {
  options.features.cli.reticulum.enable = mkEnableOption "enable reticulum";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      python313Packages.nomadnet
      python313Packages.lxmf
      rns
    ];

    home.file.".nomadnetwork/config".text = ''
      # This is the default Nomad Network config file.
      # You should probably edit it to suit your needs and use-case,

      [logging]
      # Valid log levels are 0 through 7:
      #   0: Log only critical information
      #   1: Log errors and lower log levels
      #   2: Log warnings and lower log levels
      #   3: Log notices and lower log levels
      #   4: Log info and lower (this is the default)
      #   5: Verbose logging
      #   6: Debug logging
      #   7: Extreme logging

      loglevel = 4
      destination = file

      [client]

      enable_client = yes
      user_interface = text
      downloads_path = ~/Downloads
      notify_on_new_message = yes

      # By default, the peer is announced at startup
      # to let other peers reach it immediately.
      announce_at_start = yes

      # By default, the client will try to deliver a
      # message via the LXMF propagation network, if
      # a direct delivery to the recipient is not
      # possible.
      try_propagation_on_send_fail = yes

      # Nomadnet will periodically sync messages from
      # LXMF propagation nodes by default, if any are
      # present. You can disable this if you want to
      # only sync when manually initiated.
      periodic_lxmf_sync = yes

      # The sync interval in minutes. This value is
      # equal to 6 hours (360 minutes) by default.
      lxmf_sync_interval = 360

      # By default, automatic LXMF syncs will only
      # download 8 messages at a time. You can change
      # this number, or set the option to 0 to disable
      # the limit, and download everything every time.
      lxmf_sync_limit = 8

      # You can specify a required stamp cost for
      # inbound messages to be accepted. Specifying
      # a stamp cost will require untrusted senders
      # that message you to include a cryptographic
      # stamp in their messages. Performing this
      # operation takes the sender an amount of time
      # proportional to the stamp cost. As a rough
      # estimate, a stamp cost of 8 will take less
      # than a second to compute, and a stamp cost
      # of 20 could take several minutes, even on
      # a fast computer.
      required_stamp_cost = None

      # You can signal stamp requirements to senders,
      # but still accept messages with invalid stamps
      # by setting this option to True.
      accept_invalid_stamps = False

      # The maximum accepted unpacked size for mes-
      # sages received directly from other peers,
      # specified in kilobytes. Messages larger than
      # this will be rejected before the transfer
      # begins.
      max_accepted_size = 500

      # The announce stream will only show one entry
      # per destination or node by default. You can
      # change this to show as many announces as have
      # been received, for every destination.
      compact_announce_stream = yes

      [textui]

      # Amount of time to show intro screen
      intro_time = 1

      # You can specify the display theme.
      # theme = light
      theme = dark

      # Specify the number of colors to use
      # valid colormodes are:
      # monochrome, 16, 88, 256 and 24bit
      #
      # The default is a conservative 256 colors.
      # If your terminal does not support this,
      # you can lower it. Some terminals support
      # 24 bit color.

      # colormode = monochrome
      # colormode = 16
      # colormode = 88
      # colormode = 256
      colormode = 24bit

      # By default, unicode glyphs are used. If
      # you have a Nerd Font installed, you can
      # enable this for a better user interface.
      # You can also enable plain text glyphs if
      # your terminal doesn't support unicode.

      # glyphs = plain
      # glyphs = unicode
      glyphs = nerdfont

      # You can specify whether mouse events
      # should be considered as input to the
      # application. On by default.
      mouse_enabled = True

      # What editor to use for editing text.
      editor = nvim

      # If you don't want the Guide section to
      # show up in the menu, you can disable it.
      hide_guide = no

      [node]

      # Whether to enable node hosting
      enable_node = no

      # The node name will be visible to other
      # peers on the network, and included in
      # announces.
      node_name = None

      # Automatic announce interval in minutes.
      # 6 hours by default.
      announce_interval = 360

      # Whether to announce when the node starts.
      announce_at_start = Yes

      # When Nomad Network is hosting a page-serving
      # node, it can also act as an LXMF propagation
      # node. If there is already a large amount of
      # propagation nodes on the network, or you
      # simply want to run a pageserving-only node,
      # you can disable running a propagation node.
      # Due to lots of propagation nodes being
      # available, this is currently the default.
      disable_propagation = Yes

      # The maximum amount of storage to use for
      # the LXMF Propagation Node message store,
      # specified in megabytes. When this limit
      # is reached, LXMF will periodically remove
      # messages in its message store. By default,
      # LXMF prioritises keeping messages that are
      # new and small. Large and old messages will
      # be removed first. This setting is optional
      # and defaults to 2 gigabytes.
      # message_storage_limit = 2000

      # The maximum accepted transfer size per in-
      # coming propagation transfer, in kilobytes.
      # This also sets the upper limit for the size
      # of single messages accepted onto this node.
      #
      # If a node wants to propagate a larger number
      # of messages to this node, than what can fit
      # within this limit, it will prioritise sending
      # the smallest, newest messages first, and try
      # with any remaining messages at a later point.
      max_transfer_size = 256

      # You can tell the LXMF message router to
      # prioritise storage for one or more
      # destinations. If the message store reaches
      # the specified limit, LXMF will prioritise
      # keeping messages for destinations specified
      # with this option. This setting is optional,
      # and generally you do not need to use it.
      # prioritise_destinations = 41d20c727598a3fbbdf9106133a3a0ed, d924b81822ca24e68e2effea99bcb8cf

      # You can configure the maximum number of other
      # propagation nodes that this node will peer
      # with automatically. The default is 50.
      # max_peers = 25

      # You can configure a list of static propagation
      # node peers, that this node will always be
      # peered with, by specifying a list of
      # destination hashes.
      # static_peers = e17f833c4ddf8890dd3a79a6fea8161d, 5a2d0029b6e5ec87020abaea0d746da4

      # You can specify the interval in minutes for
      # rescanning the hosted pages path. By default,
      # this option is disabled, and the pages path
      # will only be scanned on startup.
      # page_refresh_interval = 0

      # You can specify the interval in minutes for
      # rescanning the hosted files path. By default,
      # this option is disabled, and the files path
      # will only be scanned on startup.
      # file_refresh_interval = 0

      [printing]

      # You can configure Nomad Network to print
      # various kinds of information and messages.

      # Printing messages is disabled by default
      print_messages = No

      # You can configure a custom template for
      # message printing. If you uncomment this
      # option, set a path to the template and
      # restart Nomad Network, a default template
      # will be created that you can edit.
      # message_template = ~/.nomadnetwork/print_template_msg.txt

      # You can configure Nomad Network to only
      # print messages from trusted destinations.
      # print_from = trusted

      # Or specify the source LXMF addresses that
      # will automatically have messages printed
      # on arrival.
      # print_from = 76fe5751a56067d1e84eef3e88eab85b, 0e70b5848eb57c13154154feaeeb89b7

      # Or allow printing from anywhere, if you
      # are feeling brave and adventurous.
      # print_from = everywhere

      # You can configure the printing command.
      # This will use the default CUPS printer on
      # your system.
      print_command = lp

      # You can specify what printer to use
      # print_command = lp -d [PRINTER_NAME]

      # Or specify more advanced options. This
      # example works well for small thermal-
      # roll printers:
      # print_command = lp -d [PRINTER_NAME] -o cpi=16 -o lpi=8

      # This one is more suitable for full-sheet
      # printers. It will print a QR code at the center of any media
      # your printer will accept, print in portrait mode, and move the message to
      # the top of the print queue:
      # print_command = lp -d [PRINTER_NAME] -o job-priority=100 -o media=Custom.75x75mm -o orientation-requested=3

      # But you can modify the size to fit your needs.
      # The custom media option accepts millimeters, centimeters, and
      # inches in a width by length format like so:
      # -o media=Custom.[WIDTH]x[LENGTH][mm,cm,in]
      #
      # The job priority option accepts 1-100, though you can remove it
      # entirely if you aren't concerned with a print queue:
      # -o job-priority=[1-100]
      #
      # Finally, the orientation option allows for 90 degree rotations beginning with 3, so:
      # -o orientation-requested=4 (landscape, 90 degrees)
      # -o orientation-requested=5 (reverse portrait, 180 degrees)
      #
      # Here is the full command with the recommended customizable variables:
      # print_command = lp -d [PRINTER_NAME] -o job-priority=[N] -o media=[MEDIA_SIZE] -o orientation-requested=[N] -o sides=one-sided

      # For example, here's a configuration for USB thermal printer that uses the POS-58 PPD driver
      # with rolls 47.98x209.9mm in size:
      # print_command = lp -d [PRINTER_NAME] -o job-priority=100 -o media=custom_47.98x209.9mm_47.98x209.9mm -o sides=one-sided
    '';

    home.file.".reticulum/config".text = ''
      # This is the default Reticulum config file.
      # You should probably edit it to include any additional,
      # interfaces and settings you might need.

      # Only the most basic options are included in this default
      # configuration. To see a more verbose, and much longer,
      # configuration example, you can run the command:
      # rnsd --exampleconfig


      [reticulum]

        # If you enable Transport, your system will route traffic
        # for other peers, pass announces and serve path requests.
        # This should only be done for systems that are suited to
        # act as transport nodes, ie. if they are stationary and
        # always-on. This directive is optional and can be removed
        # for brevity.

        enable_transport = False


        # By default, the first program to launch the Reticulum
        # Network Stack will create a shared instance, that other
        # programs can communicate with. Only the shared instance
        # opens all the configured interfaces directly, and other
        # local programs communicate with the shared instance over
        # a local socket. This is completely transparent to the
        # user, and should generally be turned on. This directive
        # is optional and can be removed for brevity.

        share_instance = Yes


        # If you want to run multiple *different* shared instances
        # on the same system, you will need to specify different
        # instance names for each. On platforms supporting domain
        # sockets, this can be done with the instance_name option:

        instance_name = default

      # Some platforms don't support domain sockets, and if that
      # is the case, you can isolate different instances by
      # specifying a unique set of ports for each:

      # shared_instance_port = 37428
      # instance_control_port = 37429


      # If you want to explicitly use TCP for shared instance
      # communication, instead of domain sockets, this is also
      # possible, by using the following option:

      # shared_instance_type = tcp


      # You can configure Reticulum to panic and forcibly close
      # if an unrecoverable interface error occurs, such as the
      # hardware device for an interface disappearing. This is
      # an optional directive, and can be left out for brevity.
      # This behaviour is disabled by default.

      # panic_on_interface_error = No


      [logging]
        # Valid log levels are 0 through 7:
        #   0: Log only critical information
        #   1: Log errors and lower log levels
        #   2: Log warnings and lower log levels
        #   3: Log notices and lower log levels
        #   4: Log info and lower (this is the default)
        #   5: Verbose logging
        #   6: Debug logging
        #   7: Extreme logging

        loglevel = 4


      # The interfaces section defines the physical and virtual
      # interfaces Reticulum will use to communicate on. This
      # section will contain examples for a variety of interface
      # types. You can modify these or use them as a basis for
      # your own config, or simply remove the unused ones.

      [interfaces]

        # This interface enables communication with other
        # link-local Reticulum nodes over UDP. It does not
        # need any functional IP infrastructure like routers
        # or DHCP servers, but will require that at least link-
        # local IPv6 is enabled in your operating system, which
        # should be enabled by default in almost any OS. See
        # the Reticulum Manual for more configuration options.

        [[Default Interface]]
          type = AutoInterface
          enabled = Yes
        [[Beleth]]
          type = TCPClientInterface
          enabled = yes
          target_host = rns.beleth.net
          target_port = 4242

        [[acehoss]]
          type = TCPClientInterface
          enabled = yes
          target_host = rns.acehoss.net
          target_port = 4242

        [[SparkN0de-ext1 tcp]]
          type = TCPClientInterface
          enabled = yes
          target_host = aspark.uber.space
          target_port = 44860

        [[RNS_Transport_US-East]]
          type = TCPClientInterface
          enabled = yes
          target_host = 45.77.109.86
          target_port = 4965

        [[Tidudanka.com]]
          type = TCPClientInterface
          enabled = yes
          target_host = 164.90.180.40
          target_port = 37500

        [[vicinanza]]
          type = TCPClientInterface
          enabled = yes
          target_host = reticulum.vicinanza.org
          target_port = 4242

        [[undique]]
          type = TCPClientInterface
          enabled = yes
          target_host = rns.undique.tech
          target_port = 4242

        [[RNS TCP Node Germany 002]]
          type = TCPClientInterface
          enabled = yes
          target_host = 193.26.158.230
          target_port = 4965

        [[HiddenPath]]
          type = TCPClientInterface
          enabled = yes
          target_host = hiddenpath.network
          target_port = 4242

        [[N7EKB]]
          type = TCPClientInterface
          enabled = yes
          target_host = reticulum.n7ekb.net
          target_port = 48086

        [[rmap.world]]
          type = TCPClientInterface
          enabled = yes
          target_host = rmap.world
          target_port = 4242

        [[XZ Group Casiopea]]
          type = TCPClientInterface
          enabled = yes
          target_host = iu1botvash.ddns.net
          target_port = 4242

        [[SwissLibertarian]]
          type = TCPClientInterface
          enabled = yes
          target_host = 31.10.149.60
          target_port = 5001

        [[bnZ-RET01]]
          type = TCPClientInterface
          enabled = yes
          target_host = node01.rns.bnz.se
          target_port = 4242

        [[RNS Belgium]]
          type = TCPClientInterface
          enabled = yes
          target_host = be.rns.hamesh.eu
          target_port = 8694

        [[RNS Node Spain]]
          type = TCPClientInterface
          enabled = yes
          target_host = reticulum.quixote.network
          target_port = 4242

        [[Rothbard Node]]
          type = TCPClientInterface
          enabled = yes
          target_host = rothbard.lab.networks.deavmi.assigned.ne
          target_port = 4242

        [[Chicago Potato]]
          type = TCPClientInterface
          enabled = yes
          target_host = rns.rishipanthee.com
          target_port = 4242

        [[GhostNet LoRa]]
          type = TCPClientInterface
          enabled = yes
          target_host = kennel.itsg.host
          target_port = 4242

        [[Sydney RNS]]
          type = TCPClientInterface
          enabled = yes
          target_host = sydney.reticulum.au
          target_port = 4242

        [[NomadNode SEAsia]]
          type = TCPClientInterface
          enabled = yes
          target_host = rns.jaykayenn.net
          target_port = 4242

        [[rtclm.de]]
          type = TCPClientInterface
          enabled = yes
          target_host = rtclm.de
          target_port = 4242

        [[chloe serv]]
          type = TCPClientInterface
          enabled = yes
          target_host = pvvv.vea.st
          target_port = 4242

        [[ON6ZQ]]
          type = TCPClientInterface
          enabled = yes
          target_host = reticulum.on6zq.be
          target_port = 4965

        [[Jon]]
          type = TCPClientInterface
          enabled = yes
          target_host = rns.jlamothe.net
          target_port = 4242

        [[FireZen]]
          type = TCPClientInterface
          enabled = yes
          target_host = firezen.com
          target_port = 4242

        [[0rbit-Net TCP]]
          type = TCPClientInterface
          enabled = yes
          target_host = 93.95.227.8
          target_port = 49952
    '';
  };
}
