using System; using System.IO; using System.Collections.Generic; using System.Linq;
using System.Threading; using System.Reflection; using System.Security.Cryptography;
using SteamKit2;
using SteamKit2.Authentication; /// brings in steam login
using SteamKit2.Internal; /// brings in protobuf client messages
using SteamKit2.GC; /// brings in the GC related classes
using SteamKit2.GC.Dota.Internal; /// brings in dota specific protobuf messages like CMsgDOTAMatch

/// AveYo: adapted from SteamKit2 Samples
class Program
{
    const int APPID = 570; /// dota2's appid
    static public List<CMsgDOTAGetPlayerMatchHistoryResponse.Match> Matches { get; private set; }
    static SteamClient steamClient; static CallbackManager manager; static SteamGameCoordinator coordinator;
    static SteamUser steamUser;
    static string user; static string pass; static string arg0; static string arg1;
    static ulong  matches_start_at_id;
    static uint   matches_remaining;
    static uint   matches_count;
    static uint   account;
    static bool   isRunning;

    static void Main(string[] args)
    {
        Console.WriteLine("Usage:");
        Console.WriteLine("ShowMMR steam_user steam_pass [optional] matches_count or 200 [optional] matches_start_at_id or last");
        Console.WriteLine();
        if ( args.Length == 0 )
        {
            Console.Error.Write("Steam login user: ");
            arg0 = Console.ReadLine()?.Trim();
        }
        if ( args.Length < 2)
        {
            Console.Error.Write("Steam login pass: ");
            arg1 =  Console.ReadLine()?.Trim();
        }

        /// save our logon details
        user = args.Length == 0 ? arg0 : args[ 0 ];
        pass = args.Length < 2 ? arg1 : args[ 1 ];

        matches_count = 200;
        if ( args.Length > 2 && !uint.TryParse( args[ 2 ], out matches_count ) )
        {
            Console.Error.WriteLine( "Invalid 3rd arg matches_count! Try 20 - 360" );
            Console.ReadKey();
            return;
        }

        matches_start_at_id = 0;
        if ( args.Length > 3 && !ulong.TryParse( args[ 3 ], out matches_start_at_id ) )
        {
            Console.Error.WriteLine( "Invalid 4th arg matches_start_at_id! Try a match_id" );
            Console.ReadKey();
            return;
        }

        matches_remaining = matches_count;
        Matches = new List<CMsgDOTAGetPlayerMatchHistoryResponse.Match>();
        account = 0;

        /// create our steamclient instance
        steamClient = new SteamClient();
        /// create the callback manager which will route callbacks to function calls
        manager = new CallbackManager( steamClient );

        /// get the steamuser handler, which is used for logging on after successfully connecting
        steamUser = steamClient.GetHandler<SteamUser>();
        /// get the GC
        coordinator = steamClient.GetHandler<SteamGameCoordinator>();

        /// register a few callbacks we're interested in
        /// these are registered upon creation to a callback manager, which will then route the callbacks
        /// to the functions specified
        manager.Subscribe<SteamClient.ConnectedCallback>( OnConnected );
        manager.Subscribe<SteamClient.DisconnectedCallback>( OnDisconnected );
        manager.Subscribe<SteamUser.LoggedOnCallback>( OnLoggedOn );
        manager.Subscribe<SteamUser.LoggedOffCallback>( OnLoggedOff );

        /// GC message
        manager.Subscribe<SteamGameCoordinator.MessageCallback>( OnGCMessage );

        isRunning = true;

        Console.WriteLine( "Connecting to Steam..." );

        /// initiate the connection
        steamClient.Connect();

        /// create our callback handling loop
        while ( isRunning )
        {
            /// in order for the callbacks to get routed, they need to be handled by the manager
            manager.RunWaitCallbacks( TimeSpan.FromSeconds( 1 ) );
        }

        /// print off what steam gave us
        Console.WriteLine( "{1}Results for account {0}{1}", account, Environment.NewLine );

        if ( Matches == null )
        {
            Console.WriteLine( "No results to display!" );
            Console.ReadKey();
            return;
        }

        var mmr_history = new System.Text.StringBuilder();
        mmr_history.AppendFormat("\"config\"\r\n{{\r\n\t\"bindings\"\r\n\t{{\r\n\t\t\"JOY1\"\t\t\"TBD\"\r\n\t}}\r\n");
        mmr_history.AppendFormat("\t\"matches\"\r\n\t{{\r\n");

        /// use some lazy reflection to print out details
        var fields = typeof( CMsgDOTAGetPlayerMatchHistoryResponse.Match ).GetProperties(
            BindingFlags.Public | BindingFlags.Instance);

        for ( int x = 0 ; x < Matches.Count; x++ )
        {
            var m = Matches[x]; /// CMsgDOTAMatch
            Console.WriteLine( "recent_{0} = {{", x + 1);
            foreach ( var field in fields.OrderBy( f => f.Name ) )
            {
                var value = field.GetValue( m, null );

                Console.WriteLine( "  {0}: {1}", field.Name, value );
            }
            Console.WriteLine( "},");

            mmr_history.AppendFormat("\t\t{0} {{ date {1} \t mmr {2,5} \t outcome {3,5} }}\r\n",
              m.match_id, m.start_time, m.rank_change + m.previous_rank, m.rank_change);
        }
        mmr_history.AppendFormat("\t}}\r\n}}\r\n");

        /// export history to user_keys_accountid_slot3.vcfg file for ShowMMR dashboard DOTA mod
        File.WriteAllText( "user_keys_" + account.ToString() + "_slot3.vcfg", mmr_history.ToString() );

        Console.WriteLine();
        Console.WriteLine( "Open Steam > Library > Dota2 > right-click Properties > Installed files > Browse..");
        Console.WriteLine( "And replace game/dota/cfg/user_keys_{0}_slot3.vcfg with the generated file!", account.ToString());
        Console.ReadKey();
    }

    static async void OnConnected( SteamClient.ConnectedCallback callback )
    {
        Console.WriteLine( "Connected to Steam! Logging in '{0}'...", user );

        var cached_auth = user + ".auth";

        if ( File.Exists( cached_auth ) )
        {
            var reAccessToken = File.ReadAllText( cached_auth, System.Text.Encoding.ASCII );
            /// Logon to Steam with the access token we have saved
            steamUser.LogOn( new SteamUser.LogOnDetails
            {
                Username = user,
                AccessToken = reAccessToken,
            } );

        }
        else
        {
            /// Begin authenticating via credentials
            var authSession = await steamClient.Authentication.BeginAuthSessionViaCredentialsAsync(
                new AuthSessionDetails
                {
                    Username = user,
                    Password = pass,
                    IsPersistentSession = false,
                    Authenticator = new UserConsoleAuthenticator(),
                }
            );

            /// Starting polling Steam for authentication response
            var pollResponse = await authSession.PollingWaitForResultAsync();

            Console.WriteLine(pollResponse.AccountName);
            Console.WriteLine(pollResponse.AccessToken);
            File.WriteAllText( cached_auth, pollResponse.RefreshToken, System.Text.Encoding.ASCII);

            /// Logon to Steam with the access token we have received
            /// Note that we are using RefreshToken for logging on here
            steamUser.LogOn( new SteamUser.LogOnDetails
            {
                Username = pollResponse.AccountName,
                AccessToken = pollResponse.RefreshToken,
            } );
        }
    }

    static void OnDisconnected( SteamClient.DisconnectedCallback callback )
    {
        Console.WriteLine( "Disconnected from Steam" );

        isRunning = false;
    }

    static void OnLoggedOn( SteamUser.LoggedOnCallback callback )
    {
        if ( callback.Result != EResult.OK )
        {
            Console.WriteLine( "Unable to logon to Steam: {0} / {1}", callback.Result, callback.ExtendedResult );

            isRunning = false;
            return;
        }

        account = steamUser.SteamID.AccountID;

        /// at this point, we'd be able to perform actions on Steam
        Console.WriteLine( "Logged in! Launching DOTA..." );

        /// we've logged into the account
        /// now we need to inform the steam server that we're playing dota (in order to receive GC messages)

        /// steamkit doesn't expose the "play game" message through any handler, so we'll just send the message manually
        var playGame = new ClientMsgProtobuf<CMsgClientGamesPlayed>( EMsg.ClientGamesPlayed );

        playGame.Body.games_played.Add( new CMsgClientGamesPlayed.GamePlayed
        {
            game_id = new GameID( APPID ), /// or game_id = APPID,
        } );

        /// send it off
        /// notice here we're sending this message directly using the SteamClient
        steamClient.Send( playGame );

        /// delay a little to give steam some time to establish a GC connection to us
        Thread.Sleep( 5000 );

        /// inform the dota GC that we want a session
        var clientHello = new ClientGCMsgProtobuf<SteamKit2.GC.Dota.Internal.CMsgClientHello>(
            ( uint )EGCBaseClientMsg.k_EMsgGCClientHello );
        clientHello.Body.engine = ESourceEngine.k_ESE_Source2;
        coordinator.Send( clientHello, APPID );
    }

    static void OnLoggedOff( SteamUser.LoggedOffCallback callback )
    {
        Console.WriteLine( "Logged off of Steam: {0}", callback.Result );
    }

    /// called when a gamecoordinator (GC) message arrives
    /// these kinds of messages are designed to be game-specific
    /// in this case, we'll be handling dota's GC messages
    static void OnGCMessage( SteamGameCoordinator.MessageCallback callback )
    {
        /// setup our dispatch table for messages
        /// this makes the code cleaner and easier to maintain
        var messageMap = new Dictionary<uint, Action<IPacketGCMsg>>
            {
                { ( uint )EGCBaseClientMsg.k_EMsgGCClientWelcome, OnClientWelcome },
                { ( uint )EDOTAGCMsg.k_EMsgDOTAGetPlayerMatchHistoryResponse, OnMatchHistory },
            };

        Action<IPacketGCMsg> func;
        if ( !messageMap.TryGetValue( callback.EMsg, out func ) )
        {
            /// this will happen when we recieve some GC messages that we're not handling
            /// this is okay because we're handling every essential message, and the rest can be ignored
            return;
        }

        func( callback.Message );
    }

    /// this message arrives when the GC welcomes a client
    /// this happens after telling steam that we launched dota (with the ClientGamesPlayed message)
    /// this can also happen after the GC has restarted (due to a crash or new version)
    static void OnClientWelcome( IPacketGCMsg packetMsg )
    {
        /// in order to get at the contents of the message, we need to create a ClientGCMsgProtobuf from the packet message we recieve
        /// note here the difference between ClientGCMsgProtobuf and the ClientMsgProtobuf used when sending ClientGamesPlayed
        /// this message is used for the GC, while the other is used for general steam messages
        var msg = new ClientGCMsgProtobuf<CMsgClientWelcome>( packetMsg );

        Console.WriteLine( "GC is welcoming us. Version: {0}", msg.Body.version );

        /// at this point, the GC is now ready to accept messages from us
        Console.WriteLine( "Requesting {0} recent matches history", matches_count);
        var matches_requested = Math.Min(20, matches_count);
        matches_remaining -= matches_requested;
        var requestHistory = new ClientGCMsgProtobuf<CMsgDOTAGetPlayerMatchHistory>(
            (uint) EDOTAGCMsg.k_EMsgDOTAGetPlayerMatchHistory );
        requestHistory.Body.account_id = steamUser.SteamID.AccountID;
        requestHistory.Body.matches_requested = matches_requested;
        if (matches_start_at_id > 0)
            requestHistory.Body.start_at_match_id = matches_start_at_id;
        coordinator.Send( requestHistory, APPID );
    }

    /// this message arrives after we've requested the details for a match
    static void OnMatchHistory( IPacketGCMsg packetMsg )
    {
        var msg = new ClientGCMsgProtobuf<CMsgDOTAGetPlayerMatchHistoryResponse>( packetMsg );

        isRunning  = true;
        Matches.AddRange(msg.Body.matches);

        if (matches_remaining <= 0)
        {
            /// we've got everything we need, we can disconnect from steam now
            Thread.Sleep( 1000 );
            steamClient.Disconnect();
        }
        else
        {
            Thread.Sleep( 1000 );
            var start_at_match_id = msg.Body.matches[msg.Body.matches.Count -1].match_id;
            Console.WriteLine( "Matches remaining: {0} start at: {1}", matches_remaining, start_at_match_id);
            var matches_requested = Math.Min(20, matches_remaining);
            matches_remaining -= matches_requested;

            var requestHistory = new ClientGCMsgProtobuf<CMsgDOTAGetPlayerMatchHistory>(
                (uint) EDOTAGCMsg.k_EMsgDOTAGetPlayerMatchHistory );
            requestHistory.Body.account_id = steamUser.SteamID.AccountID;
            requestHistory.Body.matches_requested = matches_requested;
            requestHistory.Body.start_at_match_id = start_at_match_id;
            coordinator.Send( requestHistory, APPID );
        }
    }
}

