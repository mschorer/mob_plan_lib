package de.ms_ite.mobile.topplan {
	import com.adobe.crypto.MD5;
	
	import de.ms_ite.maptech.symbols.styles.SymbolStyle;
	import de.ms_ite.mobile.topplan.events.TopEvent;
	
	import flash.data.SQLResult;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.Responder;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	import models.Model;
	import models.RetrievalParameters;
	import models.SignsIcon;
	import models.SignsModel;
	import models.SignsOwner;
	import models.SignsProject;
	import models.SignsTag;
	import models.SignsUser;
	
	import mx.collections.ArrayCollection;

	public class AppSettings extends EventDispatcher {
		
		protected static var _user:SignsUser;
		protected static var _userMap:ArrayCollection;
		
		protected static var _forcePlatform:Boolean = false;
		protected static var _forceDesktop:Boolean = false;
		protected static var _detectedPlatform:Boolean;
		protected static var _platformDetected:Boolean = false;
		
		protected static var _currentProject:SignsProject;
		protected static var _workingProject:SignsProject;
		
		protected static var _workingOwner:SignsOwner;
		protected static var _workingTag:SignsTag;
		protected static var _workingIcon:SignsIcon;
		
		protected static var _onlineMode:Boolean = true;
		
		protected static var _securitySalt:String = 'topplanS3cur1tyS33d';

		protected static var _baseUrl:String = "http://app.topplan.de/";
		protected static var _uploadScript:String = "upload.php";
		protected static var _uploadDBScript:String = "uploadDB.php";
		protected static var _imageRootPath:String = "img";
		protected static var _imageOffsetPath:String = "items";
		
		protected static var _dbImagePath:String = "app/webroot/debug/database/image.db";

		protected static var _persistentStoragePath:String = ".";
		protected static var _persistentStorage:File;
		protected static var _databaseStoragePath:String = ".";
		protected static var _databaseStorage:File;

		protected static var _imageSizePath:String = "images/view";
		
		protected static var _imageAccessOnline:Boolean = false;

		protected static var _imageDownloadWidth:int = 400;
		protected static var _imageDownloadHeight:int = 300;
		protected static var _imageDownloadScaleup:int = 0;		
		
		protected static var _iconDownloadWidth:int = 120;
		protected static var _iconDownloadHeight:int = 120;
		protected static var _iconDownloadScaleup:int = 0;
		
		protected static var _localImagePath:String = "files/cam";
		
		protected static var _versionNumber:String;

		protected static var _itemConnectionXML:XMLList = new XMLList( '' +
			'<item name="Fundament" data="10">' +
				'<item name="---" data="0"/>' +
				'<item name="unbefestigt" data="10"/>' +
				'<item name="Kies" data="20"/>' +
				'<item name="Grünfläche" data="28"/>' +
				'<item name="Asphalt" data="30"/>' +
				'<item name="Pflaster" data="40"/>' +
				'<item name="Beton" data="50"/>' +
				'<item name="sonstiges" data="ff"/>' +
			'</item>' +
			'<item name="Befestigung" data="20">' +
				'<item name="---" data="0"/>' +
				'<item name="Klemmschelle" data="10" default="true"/>' +
				'<item name="Rohrschelle, l=70 mm" data="20"/>' +
				'<item name="Rohrschelle, l=350 mm" data="22"/>' +
				'<item name="Rohrschelle, l=500 mm" data="24"/>' +
				'<item name="Band seitlich" data="40"/>' +
				'<item name="Bandschelle, l=70 mm" data="60"/>' +
				'<item name="Bandschelle, l=350 mm" data="70"/>' +
				'<item name="Bandschelle, l=500 mm" data="80"/>' +
				'<item name="U-Schiene" data="90"/>' +
				'<item name="Vario-Schellen" data="15"/>' +
				'<item name="Holzschrauben" data="a0"/>' +
				'<item name="Schrauben (Wand)" data="b0"/>' +
				'<item name="Doppelklemmschelle" data="c0" />' +
				'<item name="Klemmschelle 2-fach" data="d0"/>' +
				'<item name="sonstiges" data="ff"/>' +
			'</item>' +
			'<item name="Seiten" data="28">' +
				'<item name="---" data="0"/>' +
				'<item name="einseitig" data="10"/>' +
				'<item name="beidseitig" data="40"/>' +
				'<item name="vorne" data="20"/>' +
				'<item name="hinten" data="30"/>' +
			'</item>' +
			'<item name="Einhänger" data="201050">' +
				'<item name="---" data="0"/>' +
				'<item name="Omega" data="10"/>' +
				'<item name="Schwalbenschwanz" data="20"/>' +
				'<item name="Kreuz" data="30"/>' +
				'<item name="T" data="40"/>' +
				'<item name="Pilz" data="50"/>' +
				'<item name="Doppel-T" data="44"/>' +
				'<item name="Fuvial" data="60"/>' +
			'</item>' +
			'<item name="Einhänger" data="207050">' +
				'<item name="---" data="0"/>' +
				'<item name="Omega" data="10"/>' +
				'<item name="Schwalbenschwanz" data="20"/>' +
				'<item name="Kreuz" data="30"/>' +
				'<item name="T" data="40"/>' +
				'<item name="Pilz" data="50"/>' +
				'<item name="Doppel-T" data="44"/>' +
				'<item name="Fuvial" data="60"/>' +
			'</item>'
		);
	
		protected static var _itemLengthXML:XMLList = new XMLList( '' +
			'<item name="Länge" data="10">' +
				'<item name="---" data="0"/>' +
				'<item name="1,50 m" data="15"/>' +
				'<item name="2,00 m" data="20"/>' +
				'<item name="2,50 m" data="25"/>' +
				'<item name="3,00 m" data="30"/>' +
				'<item name="3,50 m" data="35"/>' +
				'<item name="4,00 m" data="40"/>' +
				'<item name="über 4,00 m" data="99"/>' +
				'<item name="0,50 m Verlängerung" data="5"/>' +
				'<item name="1,00 m Verlängerung" data="10"/>' +
			'</item>');
	
		protected static var _itemFormatXML:XMLList = new XMLList( '' +
			'<item name="Durchmesser" data="10">' +		// träger
				'<item name="---" data="0"/>' +
				'<item name="60 mm" data="60"/>' +
				'<item name="76 mm" data="76"/>' +
				'<item name="unter 60 mm" data="55"/>' +
				'<item name="eckig" data="ec"/>' +
				'<item name="60 – 80 mm" data="80"/>' +
				'<item name="80 – 100 mm" data="100"/>' +
				'<item name="100 – 120 mm" data="120"/>' +
				'<item name="über 120 mm" data="125"/>' +
			'</item>' +
			'<item name="Format" data="2010">' +		// rad
				'<item name="---" data="0"/>' +
				'<item name="150 x 500 mm" data="150500"/>' +
				'<item name="150 x 600 mm" data="150600"/>' +
				'<item name="150 x 650 mm" data="150650"/>' +
				'<item name="150 x 800 mm" data="150800"/>' +
				'<item name="200 x 800 mm" data="200800" default="true"/>' +
				'<item name="250 x 800 mm" data="250800"/>' +
				'<item name="250 x 1000 mm" data="2501000"/>' +
				'<item name="Sondergröße" data="1"/>' +				
			'</item>' +
			'<item name="Format" data="201020">' +		//zwischen
				'<item name="---" data="0"/>' +
				'<item name="200 x 200 mm" data="200200"/>' +
				'<item name="250 x 250 mm" data="250250"/>' +
				'<item name="300 x 300 mm" data="300300"/>' +
				'<item name="Sondergröße" data="1"/>' +				
			'</item>' +
			'<item name="Format" data="201050">' +		//einhänger rad
				'<item name="---" data="0"/>' +
				'<item name="100 x 100 mm" data="100100"/>' +
				'<item name="100 x 200 mm" data="100200"/>' +
				'<item name="150 x 150 mm" data="150150" default="true"/>' +
				'<item name="150 x 200 mm" data="150200"/>' +
				'<item name="150 x 300 mm" data="150300"/>' +
				'<item name="Sondergröße" data="1"/>' +				
			'</item>' +
			'<item name="Format" data="2028">' +		// leitsystem
				'<item name="---" data="0"/>' +
				'<item name="120 x 495 mm" data="120495"/>' +
				'<item name="120 x 570 mm" data="120570"/>' +
				'<item name="150 x 650 mm" data="150650"/>' +
				'<item name="150 x 800 mm" data="150800"/>' +
				'<item name="200 x 800 mm" data="200800"/>' +
				'<item name="200 x 1000 mm" data="2001000"/>' +
				'<item name="250 x 1000 mm" data="2501000"/>' +
				'<item name="Sondergröße" data="1"/>' +				
			'</item>' +
			'<item name="Format" data="2030">' +		// wandern
				'<item name="---" data="0"/>' +
				'<item name="120 x 200 mm" data="120200"/>' +
				'<item name="120 x 260 mm" data="120260"/>' +
				'<item name="120 x 495 mm" data="120495"/>' +
				'<item name="50 x 12" data="5012"/>' +
				'<item name="20 x 12" data="2012"/>' +
				'<item name="26 x 12" data="2612"/>' +
				'<item name="Sondergröße" data="1"/>' +				
			'</item>' +
			'<item name="Format" data="2040">' +		// wandern alpin
				'<item name="---" data="0"/>' +
				'<item name="120 x 200 mm" data="120200"/>' +
				'<item name="120 x 260 mm" data="120260"/>' +
				'<item name="120 x 495 mm" data="120495"/>' +
				'<item name="50 x 12" data="5012"/>' +
				'<item name="20 x 12" data="2012"/>' +
				'<item name="26 x 12" data="2612"/>' +
				'<item name="Sondergröße" data="1"/>' +				
			'</item>' +
			'<item name="Format" data="2080">' +		// wandern tirol
				'<item name="---" data="0"/>' +
				'<item name="200 x 600 mm" data="200600"/>' +
				'<item name="200 x 400 mm" data="200400"/>' +
				'<item name="100 x 200 mm" data="100200"/>' +
				'<item name="200 x 200" data="200200"/>' +
				'<item name="120 x 200" data="120200"/>' +
				'<item name="120 x 260" data="120260"/>' +
				'<item name="120 x 495" data="120495"/>' +
				'<item name="Sondergröße" data="1"/>' +				
			'</item>' +
			'<item name="Format" data="2050">' +		// loipen
				'<item name="---" data="0"/>' +
				'<item name="50 x 12" data="5012"/>' +
				'<item name="20 x 12" data="2012"/>' +
				'<item name="26 x 12" data="2612"/>' +
				'<item name="20 x 50" data="2050"/>' +
				'<item name="35 x 50" data="3550"/>' +
				'<item name="Sondergröße" data="1"/>' +				
			'</item>' +
			'<item name="Format" data="2070">' +		// mtb
				'<item name="---" data="0"/>' +
				'<item name="150 x 650" data="150650"/>' +
				'<item name="200 x 800" data="200800"/>' +
				'<item name="250 x 250" data="250250"/>' +
				'<item name="250 x 380" data="250380"/>' +
				'<item name="50 x 12" data="5012"/>' +
				'<item name="20 x 12" data="2012"/>' +
				'<item name="26 x 12" data="2612"/>' +
				'<item name="Sondergröße" data="1"/>' +				
			'</item>' +
			'<item name="Format" data="207050">' +		//einhänger mtb
				'<item name="---" data="0"/>' +
				'<item name="100 x 100 mm" data="100100"/>' +
				'<item name="100 x 200 mm" data="100200"/>' +
				'<item name="150 x 150 mm" data="150150" default="true"/>' +
				'<item name="150 x 200 mm" data="150200"/>' +
				'<item name="150 x 300 mm" data="150300"/>' +
				'<item name="Sondergröße" data="1"/>' +				
			'</item>' +
			'<item name="Lage" data="304010">' +
				'<item name="---" data="0"/>' +
				'<item name="ausserorts" data="100"/>' +
				'<item name="innerorts" data="200"/>' +
			'</item>' +
			'<item name="Gefahrenstelle" data="3040b0">' +
				'<item name="---" data="0"/>' +
				'<item name="leicht" data="100"/>' +
				'<item name="schwer" data="200"/>' +
			'</item>' +
			'<item name="Verkehrsbelastung" data="304040">' +
				'<item name="---" data="0"/>' +
				'<item name="A: autofrei bis gering" data="05"/>' +
				'<item name="B: mäßig" data="10"/>' +
				'<item name="C: stark bis sehr stark" data="20"/>' +
				'<item name="I: autofrei" data="04"/>' +
				'<item name="II: gering" data="08"/>' +
				'<item name="III: mäßig" data="11"/>' +
				'<item name="IV: stark" data="18"/>' +
				'<item name="V: sehr stark" data="21"/>' +
				'<item name="VI: extrem" data="30"/>' +
			'</item>' +
			'<item name="Poller/Engstelle" data="304060">' +
				'<item name="---" data="0"/>' +
				'<item name="&lt; 1m" data="10"/>' +
				'<item name="1-1,30m" data="20"/>' +
				'<item name="&gt; 1,30m" data="30"/>' +
				'<item name="&gt; 1,30m mit Warnhinweis" data="34"/>' +
			'</item>' +
			'<item name="Umlaufschranke" data="304070">' +
				'<item name="---" data="0"/>' +
				'<item name="&lt; 1,50m" data="10"/>' +
				'<item name="&gt; 1,50m" data="20"/>' +
				'<item name="&gt; 1,50m mit Warnhinweis" data="24"/>' +
			'</item>' +
			'<item name="Wegezustand" data="300510">' +
				'<item name="---" data="0"/>' +
				'<item name="sehr gut" data="10"/>' +
				'<item name="gut" data="20"/>' +
				'<item name="mäßig" data="30"/>' +
				'<item name="schlecht" data="40"/>' +
				'<item name="unbefahrbar" data="50"/>' +
				'<item name="Schiebestrecke" data="60"/>' +
				'<item name="Schaden einmalig" data="70"/>' +
			'</item>' +
			'<item name="Treppe" data="300512">' +
				'<item name="---" data="0"/>' +
				'<item name="1 Stufe/Bordstein" data="1"/>' +
				'<item name="2-5 Stufen" data="5"/>' +
				'<item name="&gt;5 Stufen" data="10"/>' +
			'</item>' +
			'<item name="Wegebreite" data="300513">' +
				'<item name="---" data="0"/>' +
				'<item name="Spurweg &lt; 0,6m" data="06"/>' +
				'<item name="Spurweg &lt; 1,0m" data="08"/>' +
				'<item name="&lt; 1,0m" data="09"/>' +
				'<item name="&lt; 1,50m" data="10"/>' +
				'<item name="1,50 - 2,00m" data="15"/>' +
				'<item name="2,00 - 2,50m" data="20"/>' +
				'<item name="2,50 - 3,00m" data="25"/>' +
				'<item name="&gt; 3,0m" data="40"/>' +
				'<item name="ERRW &lt; 1,00m" data="42"/>' +
				'<item name="ERRW 1,00 - 1,50m" data="44"/>' +
				'<item name="ERRW 1,50 - 2,00m" data="46"/>' +
				'<item name="ERRW 2,00 - 2,50m" data="48"/>' +
				'<item name="ERRW &gt; 2,50m" data="4a"/>' +
			'</item>' +
			'<item name="Infotafel" data="401010">' +
				'<item name="---" data="0"/>' +
				'<item name="Rad" data="10"/>' +
				'<item name="Wandern" data="20"/>' +
				'<item name="Ortsplan" data="30"/>' +
				'<item name="Sehenswürdigkeit" data="40"/>' +
			'</item>'
		);

		protected static var _itemTypeXML:XMLList = new XMLList( '' +
				'<item name="Träger" data="10" render="post" color="d0d0d0">' +
					'<item name="---" data="1000"/>' +
					'<item name="Rohrpfosten" data="1010"/>' +
					'<item name="Lichtmast" data="1030"/>' +
					'<item name="Holzmast" data="1040"/>' +
					'<item name="Ampel" data="1080"/>' +
					'<item name="Holzpfosten" data="1020"/>' +
					'<item name="Baum" data="1050"/>' +
					'<item name="Holzwand" data="1060"/>' +
					'<item name="Mauer" data="1070"/>' +
					'<item name="Rohrpfosten 2-fach" data="1080"/>' +
					'<item name="Mast" data="1090"/>' +
					'<item name="Zaun" data="10a0"/>' +
					'<item name="sonstiges" data="10ff"/>' +
				'</item>' +
				'<item name="Wegweiser" data="20" render="sign">' +
					'<item name="---" data="2000"/>' +
					'<item name="Rad" data="2010" color="a0f0a0">' +
						'<item name="---" data="201000"/>' +
						'<item name="Pfeil" data="201010"/>' +
						'<item name="Zwischen" data="201020"/>' +
						'<item name="Tabelle 1-seitig" data="201030"/>' +
						'<item name="Tabelle 2-seitig" data="201040"/>' +
						'<item name="Einhänger" data="201050" render="subsign" color="a0a0f0"/>' +
						'<item name="Zwischen 2-seitig" data="201022"/>' +
						'<item name="Ortseingangsschild" data="201024"/>' +
					'</item>' +
					'<item name="MTB" data="2070" color="d2ffff">' +
						'<item name="---" data="207000"/>' +
						'<item name="Pfeil" data="207010"/>' +
						'<item name="Zwischen" data="207020"/>' +
						'<item name="Tabelle 1-seitig" data="207030"/>' +
						'<item name="Tabelle 2-seitig" data="207040"/>' +
						'<item name="Einhänger" data="207050" render="subsign" color="a0a0f0"/>' +
						'<item name="Sonstiges" data="207080"/>' +
					'</item>' +
					'<item name="Wandern" data="2030" color="fac850">' +
						'<item name="---" data="203000"/>' +
						'<item name="Ziel" data="203010"/>' +
						'<item name="Richtung" data="203020"/>' +
						'<item name="Richtung doppelt" data="203030"/>' +
					'</item>' +
					'<item name="Wandern Alpin" data="2040" color="fafa96">' +
						'<item name="---" data="204000"/>' +
						'<item name="Ziel" data="204010"/>' +
						'<item name="Richtung" data="204020"/>' +
						'<item name="Richtung doppelt" data="204030"/>' +
					'</item>' +
					'<item name="Wandern Tirol" data="2038" color="fafa96">' +
						'<item name="---" data="203800"/>' +
						'<item name="Ziel" data="203810"/>' +
						'<item name="Richtung" data="203820"/>' +
						'<item name="Richtung doppelt" data="203830"/>' +
						'<item name="Standorttafel" data="203840"/>' +
					'</item>' +
					'<item name="Winterwandern" data="2090" color="fac850">' +
						'<item name="---" data="209000"/>' +
						'<item name="Ziel" data="209010"/>' +
						'<item name="Richtung" data="209020"/>' +
						'<item name="Richtung doppelt" data="209030"/>' +
					'</item>' +
					'<item name="Leitsystem" data="2028" color="f0dcc8">' +
						'<item name="---" data="202800"/>' +
						'<item name="Tabelle 1-seitig grün" data="202820"/>' +
						'<item name="Tabelle 1-seitig braun" data="202824"/>' +
						'<item name="Tabelle 1-seitig weiß" data="202828"/>' +
						'<item name="Pfeil 1-seitig" data="202810"/>' +
						'<item name="Tabelle 2-seitig grün" data="202830"/>' +
						'<item name="Tabelle 2-seitig braun" data="202834"/>' +
						'<item name="Tabelle 2-seitig weiß" data="202838"/>' +
						'<item name="Pfeil 2-seitig" data="202814"/>' +
						'<item name="Tabelle klein" data="202840"/>' +
						'<item name="Sonderschild" data="2028f0"/>' +
					'</item>' +
					'<item name="Variabel" data="202c">' +
						'<item name="---" data="202c00"/>' +
					'</item>' +
					'<item name="Infotafel" data="2020">' +
						'<item name="---" data="202000"/>' +
					'</item>' +
					'<item name="Loipe" data="2050">' +
						'<item name="---" data="205000"/>' +
						'<item name="Ziel" data="205010"/>' +
						'<item name="Richtung" data="205020"/>' +
						'<item name="DSV" data="205030"/>' +
						'<item name="Straßenquerung" data="205040"/>' +
						'<item name="Starkes Gefälle" data="205050"/>' +
						'<item name="Gefahrenpunkt" data="205060"/>' +
						'<item name="Engstelle" data="205070"/>' +
					'</item>' +
					'<item name="StVO" data="2060">' +
						'<item name="---" data="206000"/>' +
						'<item name="gemeinsamer Geh- und Radweg" data="206010"/>' +
						'<item name="getrennter Geh- und Radweg" data="206018"/>' +
						'<item name="Gehweg" data="206020"/>' +
						'<item name="Radweg" data="206030"/>' +
						'<item name="Gesperrt" data="206040"/>' +
						'<item name="Gesperrt, für Rad frei" data="206050"/>' +
						'<item name="Privatweg" data="206060"/>' +
						'<item name="Sonstiges" data="2060ff"/>' +
					'</item>' +
				'</item>' +
				'<item name="Beschriftung" data="28" render="label" color="f0f0c0">' +
					'<item name="Standard" data="2810"/>' +
					'<item name="klein" data="2820"/>' +
					'<item name="eng" data="2830"/>' +
					'<item name="groß" data="2840"/>' +
				'</item>' +
				'<item name="Streckeninfo" data="30" render="info">' +
					'<item name="---" data="3000"/>' +
					'<item name="Steigung/Gefälle" data="3030">' +
						'<item name="---" data="303000"/>' +
						'<item name="7%" data="303007"/>' +
						'<item name="8%" data="303008"/>' +
						'<item name="9%" data="303009"/>' +
						'<item name="10%" data="303010"/>' +
						'<item name="11%" data="303011"/>' +
						'<item name="12%" data="303012"/>' +
						'<item name="13%" data="303013"/>' +
						'<item name="14%" data="303014"/>' +
						'<item name="15%" data="303015"/>' +
						'<item name="16%" data="303016"/>' +
						'<item name="17%" data="303017"/>' +
						'<item name="18%" data="303018"/>' +
						'<item name="19%" data="303019"/>' +
						'<item name="20%" data="303020"/>' +
						'<item name="21%" data="303021"/>' +
						'<item name="22%" data="303022"/>' +
						'<item name="23%" data="303023"/>' +
						'<item name="24%" data="303024"/>' +
						'<item name="25%" data="303025"/>' +
						'<item name="26%" data="303026"/>' +
						'<item name="27%" data="303027"/>' +
						'<item name="28%" data="303028"/>' +
						'<item name="29%" data="303029"/>' +
						'<item name="30%" data="303030"/>' +
					'</item>' +
					'<item name="Belagwechsel" data="3010">' +
						'<item name="---" data="301000"/>' +
						'<item name="Asphalt – Kies" data="301010"/>' +
						'<item name="Asphalt – erdgebunden" data="301020"/>' +
						'<item name="Asphalt – Pflaster" data="301030"/>' +
						'<item name="Asphalt – staubfreie Decke" data="301040"/>' +
						'<item name="Asphalt – Beton" data="301048"/>' +
						'<item name="Kies – erdgebunden" data="301050"/>' +
						'<item name="Kies – Pflaster" data="301060"/>' +
						'<item name="Kies – staubfreie Decke" data="301070"/>' +
						'<item name="Kies – Beton" data="301078"/>' +
						'<item name="erdgebunden – staubfreie Decke" data="301080"/>' +
						'<item name="erdgebunden – Pflaster" data="301090"/>' +
						'<item name="erdgebunden – Beton" data="301098"/>' +
						'<item name="staubfreie Decke - Pflaster" data="3010a0"/>' +
						'<item name="staubfreie Decke - Beton" data="3010a8"/>' +
						'<item name="Sonstiges" data="3010ff"/>' +
					'</item>' +
					'<item name="Kategorie" data="3020">' +
						'<item name="---" data="302000"/>' +
						'<item name="MTB (leicht)" data="302010"/>' +
						'<item name="MTB (mittel)" data="302012"/>' +
						'<item name="MTB (schwer)" data="302014"/>' +
						'<item name="MTB Schiebestrecke" data="302018"/>' +
						'<item name="Geh- und Radweg" data="302020"/>' +
						'<item name="Radweg" data="302030"/>' +
						'<item name="Radfahrstreifen" data="302034"/>' +
						'<item name="Schutzstreifen Radfahrer" data="302038"/>' +
						'<item name="Gehweg" data="302040"/>' +
						'<item name="Wirtschafs-/Forstweg" data="302050"/>' +
						'<item name="Hauptverkehrsstraße" data="302060"/>' +
						'<item name="Ortsstraße" data="302070"/>' +
						'<item name="Nebenstraße" data="302080"/>' +
						'<item name="Treppe" data="302090"/>' +
						'<item name="Schiebestrecke Rad" data="3020a0"/>' +
						'<item name="Fußgängerzone" data="3020b0"/>' +
						'<item name="Parkanlage" data="3020c0"/>' +
						'<item name="Pfad (leicht)" data="3020d0"/>' +
						'<item name="Pfad (mittel)" data="3020d4"/>' +
						'<item name="Pfad (schwer)" data="3020d8"/>' +
						'<item name="alpiner Weg" data="3020e0"/>' +
						'<item name="Sonstiges" data="3020ff"/>' +
					'</item>' +
					'<item name="Gefahren" data="3040">' +
						'<item name="---" data="304000"/>' +
						'<item name="Straßenquerung" data="304010"/>' +
						'<item name="Gefahrenstelle" data="3040b0"/>' +
						'<item name="Poller/Engstelle" data="304060"/>' +
						'<item name="Umlaufschranke" data="304070"/>' +
						'<item name="Schranke" data="304080"/>' +
						'<item name="Radweg endet" data="304020"/>' +
						'<item name="Gehweg endet" data="304030"/>' +
						'<item name="Verkehrsbelastung" data="304040"/>' +
						'<item name="schneller Verkehr" data="304050"/>' +
						'<item name="Leitplanke" data="3040c0"/>' +
						'<item name="Absturzgefahr" data="304090"/>' +
						'<item name="starkes Gefälle" data="3040a0"/>' +
						'<item name="Sonstiges" data="3040ff"/>' +
					'</item>' +
					'<item name="Beeinträchtigungen" data="3005">' +
						'<item name="---" data="300500"/>' +
						'<item name="Wegezustand" data="300510"/>' +
						'<item name="Wegebreite" data="300513"/>' +
						'<item name="Treppe" data="300512"/>' +
						'<item name="Bauarbeiten" data="300514"/>' +
						'<item name="Holzarbeiten" data="300518"/>' +
						'<item name="Lärmbelastung" data="300520"/>' +
						'<item name="Staubbelastung" data="300524"/>' +
						'<item name="Geruchsbelastung" data="3005028"/>' +
						'<item name="monotone Wegführung" data="300530"/>' +
						'<item name="unnötige Höhenmeter" data="300532"/>' +
						'<item name="Umwege" data="300534"/>' +
						'<item name="nicht für Kinder" data="300540"/>' +
						'<item name="nicht für Kinderwagen" data="300542"/>' +
						'<item name="nicht für Rennrad" data="300544"/>' +
						'<item name="Routenthema verfehlt" data="300550"/>' +
						'<item name="Sonstiges" data="3005ff"/>' +
					'</item>' +
				'</item>' +
				'<item name="POI & Infrastruktur" data="40" render="poi">' +
					'<item name="---" data="4000"/>' +
					'<item name="Infrastruktur" data="4010">' +
						'<item name="---" data="401000"/>' +
						'<item name="Infotafel" data="401010"/>' +
						'<item name="Ruhebank" data="401018"/>' +
						'<item name="Ruhebank + Tisch" data="401020"/>' +
						'<item name="Relax-Liege" data="401024"/>' +
						'<item name="Rastplatz" data="401028"/>' +
						'<item name="Schutzhütte" data="401084"/>' +
						'<item name="Fahrradparken" data="4010b0"/>' +
						'<item name="Fahrradbox" data="4010b8"/>' +
						'<item name="Schließfächer" data="4010c0"/>' +
						'<item name="Fahrradstation" data="401099"/>' +
						'<item name="Radservice" data="4010a0"/>' +
						'<item name="Radwerkstatt" data="4010a8"/>' +
						'<item name="Reparaturhinweis" data="4010a9"/>' +
						'<item name="Brücke/Steg" data="401004"/>' +
						'<item name="Treppe" data="401008"/>' +
						'<item name="Geländer" data="40100c"/>' +
						'<item name="Parkplatz" data="401030"/>' +
						'<item name="Bahnhof" data="401038"/>' +
						'<item name="Bushaltestelle" data="401040"/>' +
						'<item name="Lebensmittelhandel" data="401044"/>' +
						'<item name="Touristinfo" data="401048"/>' +
						'<item name="Gastronomie" data="401050"/>' +
						'<item name="Bett & Bike" data="401058"/>' +
						'<item name="Hotel/Pension/FeWo" data="401060"/>' +
						'<item name="Camping" data="401068"/>' +
						'<item name="Wohnmobilstellplatz" data="401070"/>' +
						'<item name="Bergbahn" data="401078"/>' +
						'<item name="Bergbahn mit Radtransport" data="40107a"/>' +
						'<item name="Sessellift" data="401080"/>' +
						'<item name="Sessellift mit Radtransport" data="401082"/>' +
						'<item name="Hafen" data="401088"/>' +
						'<item name="Fähre" data="401090"/>' +
						'<item name="Fahrradverleih" data="401098"/>' +
						'<item name="Akku Ladestation" data="4010c8"/>' +
						'<item name="Akku Wechselstation" data="4010d0"/>' +
						'<item name="Foto-Point markiert" data="4010d4"/>' +
						'<item name="Sonstiges" data="4010ff"/>' +
					'</item>' +
					'<item name="POI" data="4020">' +
						'<item name="---" data="402000"/>' +
						'<item name="Pumptrack" data="402074"/>' +
						'<item name="Bikepark" data="402075"/>' +
						'<item name="Freeride-Linie" data="402076"/>' +
						'<item name="Flowtrail" data="402077"/>' +
						'<item name="Singletrail" data="402078"/>' +
						'<item name="Übungsparcours MTB" data="402079"/>' +
						'<item name="Aussicht" data="402008"/>' +
						'<item name="Kapelle" data="402010"/>' +
						'<item name="Kirche" data="402018"/>' +
						'<item name="Kloster" data="402020"/>' +
						'<item name="Kreuz, Bildstock" data="402028"/>' +
						'<item name="Grotte" data="402030"/>' +
						'<item name="Freibad" data="402038"/>' +
						'<item name="Badeweiher" data="402040"/>' +
						'<item name="Weiher" data="402048"/>' +
						'<item name="See" data="402050"/>' +
						'<item name="Liegewiese" data="402058"/>' +
						'<item name="Hallenbad" data="402060"/>' +
						'<item name="Kneippanlage" data="402068"/>' +
						'<item name="Lehrpfad" data="402070"/>' +
						'<item name="Station Lehrpfad" data="402080"/>' +
						'<item name="Schloß" data="402088"/>' +
						'<item name="Burg" data="402090"/>' +
						'<item name="Burgruine" data="402098"/>' +
						'<item name="Turm" data="4020a0"/>' +
						'<item name="Gipfel" data="4020a8"/>' +
						'<item name="Spielplatz" data="4020b0"/>' +
						'<item name="Kurpark" data="4020b8"/>' +
						'<item name="Wasserfall" data="4020c0"/>' +
						'<item name="Fluss-/Bachlauf" data="4020c8"/>' +
						'<item name="Moor" data="4020d0"/>' +
						'<item name="Denkmal" data="4020d8"/>' +
						'<item name="Naturdenkmal" data="4020e0"/>' +
						'<item name="Museum" data="4020e8"/>' +
						'<item name="Berghütte" data="4020f0"/>' +
						'<item name="Golfplatz" data="4020f8"/>' +
						'<item name="Minigolf" data="4020fc"/>' +
						'<item name="Sonstiges" data="4020ff"/>' +
					'</item>' +
					'<item name="Info" data="4005" color="e0e0f0"/>' +
				'</item>');

		protected static var _eStatusXML:XMLList = new XMLList( '' +
				'<item name="Info" data="30">' +
					'<item name="---" data="-1"/>' +
					'<item name="Standort fehlt" data="3008"/>' +
					'<item name="Standort nicht sichtbar" data="3010"/>' +
					'<item name="Standort versetzen" data="3018"/>' +
					'<item name="konkurrierende Wegweisung" data="3020"/>' +
					'<item name="Wiederspruch zu StVO" data="3028"/>' +
					'<item name="Radwegweiser entsprechen nicht dem FGSV-Standard" data="3030"/>' +
					'<item name="Wanderschilder entsprechen nicht dem regionalen Standard" data="3038"/>' +
					'<item name="Moutainbikeschilder entsprechen nicht dem regionalen Standard" data="3040"/>' +
					'<item name="durch Bewuchs verdeckt – bitte frei schneiden" data="3048"/>' +
					'<item name="Radwegweiser nur einseitig beschriftet" data="3050"/>' +
					'<item name="alle Radschilder an einen Standort montieren" data="3058"/>' +
					'<item name="alle Wanderschilder an einen Standort montieren" data="3060"/>' +
					'<item name="Sonstiges" data="ff"/>' +
				'</item>' +
				'<item name="Träger" data="10">' +
					'<item name="---" data="-1"/>' +
					'<item name="steht schief – bitte gerade setzen" data="1008"/>' +
					'<item name="durch Bewuchs verdeckt – bitte frei schneiden" data="1030"/>' +
					'<item name="konkurrierende Radwegweisung - alte Schilder abbauen" data="1098"/>' +
					'<item name="konkurrierende Wanderwegweisung - alte Schilder abbauen" data="10a0"/>' +
					'<item name="konkurrierende MTB-Wegweisung - alte Schilder abbauen" data="10a8"/>' +
					'<item name="nicht sichtbar" data="1038"/>' +
					'<item name="Radschilder fehlen komplett" data="1050"/>' +
					'<item name="Wanderschilder fehlen komplett" data="1058"/>' +
					'<item name="Mountainbikeschilder fehlen komplett" data="1060"/>' +
					'<item name="beschädigt – Reparatur möglich" data="1010"/>' +
					'<item name="beschädigt – Austausch erforderlich" data="1018"/>' +
					'<item name="korrodiert" data="1020"/>' +
					'<item name="durch längeren Pfosten ersetzen" data="1028"/>' +
					'<item name="versetzen" data="1048"/>' +
					'<item name="nicht vorhanden" data="1040"/>' +
					'<item name="Radwegweiser entsprechen nicht dem FGSV-Standard" data="1068"/>' +
					'<item name="Wanderschilder entsprechen nicht dem regionalen Standard" data="1070"/>' +
					'<item name="Moutainbikeschilder entsprechen nicht dem regionalen Standard" data="1078"/>' +
					'<item name="alle Radschilder an einen Standort montieren" data="1080"/>' +
					'<item name="alle Wanderschilder an einen Standort montieren" data="1088"/>' +
					'<item name="Widerspruch zu StVO" data="1090"/>' +
					'<item name="Sonstiges" data="ff"/>' +
				'</item>' +
				'<item name="Wegweiser" data="20">' +
					'<item name="---" data="-1"/>' +
					'<item name="nicht vorhanden" data="2020"/>' +
					'<item name="verschmutzt – bitte säubern" data="2060"/>' +
					'<item name="ergänzen" data="2084" enabled="false"/>' +
					'<item name="zeigt in falsche Richtung - bitte neu ausrichten" data="2040"/>' +
					'<item name="ausgebleicht – Austausch wird empfohlen" data="2078"/>' +
					'<item name="ausgebleicht – Austausch noch nicht erforderlich" data="2070"/>' +
					'<item name="Wegweiser entspricht nicht Datenbank" data="20c8"/>' +
					'<item name="stark beschädigt – Austausch erforderlich" data="2010"/>' +
					'<item name="beschädigt - Austausch noch nicht erforderlich" data="2018"/>' +
					'<item name="verbogen" data="2038"/>' +
					'<item name="Nachbestellung" data="20d0"/>' +
					'<item name="nicht sichtbar" data="2024"/>' +
					'<item name="hat Risse – Austausch noch nicht erforderlich" data="2028"/>' +
					'<item name="hat Risse – Austausch wird empfohlen" data="2030"/>' +
					'<item name="nicht waagrecht – bitte neu montieren" data="2048"/>' +
					'<item name="überklebt – bitte säubern" data="2050"/>' +
					'<item name="übermalt – bitte säubern" data="2058"/>' +
					'<item name="mit falscher Pfeilrichtung" data="2068"/>' +
					'<item name="Schreibfehler" data="2082"/>' +
					'<item name="Lichtraum beeinträchtigt" data="2008"/>' +
					'<item name="Aufkleber ersetzen" data="2088"/>' +
					'<item name="Aufkleber anbringen" data="2090"/>' +
					'<item name="Wegweiser nur einseitig beschriftet" data="20b0"/>' +
					'<item name="Ausrichtung von topplan vor Ort korrigiert" data="20d8"/>' +
					'<item name="Aufkleber von topplan ergänzt" data="20e0"/>' +
					'<item name="von topplan abgebaut und neu montiert" data="20e8"/>' +
					'<item name="Sonstiges" data="ff"/>' +

					'<item name="Einhängeplakette ergänzen" data="20d0"/>' +
					'<item name="Einhängeplakette ausgebleicht - Austausch noch nicht erforderlich" data="20d2"/>' +
					'<item name="Einhängeplakette ausgebleicht - Austausch wird empfohlen" data="20d4"/>' +

					'<item name="Radwegweiser entsprechen nicht dem FGSV-Standard" data="2098"/>' +
					'<item name="Wanderschilder entsprechen nicht dem regionalen Standard" data="20a0"/>' +
					'<item name="Moutainbikeschilder entsprechen nicht dem regionalen Standard" data="20a8"/>' +
					'<item name="alle Radschilder an einen Standort montieren" data="20b8"/>' +
					'<item name="alle Wanderschilder an einen Standort montieren" data="20c0"/>' +
					
					'<item name="durch Bewuchs verdeckt – bitte frei schneiden" data="2022"/>' +
					'<item name="verbogen" data="2038"/>' +
					'<item name="mangelhafte Beschriftung" data="2080"/>' +
				'</item>' +
				'<item name="Wegezustand" data="3030">' +
					'<item name="---" data="0"/>' +
					'<item name="Wegebelag" data="303008"/>' +
					'<item name="Querrillen" data="303010"/>' +
					'<item name="Geländer" data="303018"/>' +
					'<item name="Absturzsicherung fehlt" data="303020"/>' +
					'<item name="Treppe" data="303028"/>' +
					'<item name="Brücke" data="303030"/>' +
					'<item name="grosse Löcher" data="303038"/>' +
					'<item name="Hindernis" data="303040"/>' +
					'<item name="Baustelle" data="303048"/>' +
					'<item name="Holzarbeiten" data="303050"/>' +
					'<item name="Sonstiges" data="ff"/>' +
				'</item>');
		
		/* +
				'<item name="Infrastruktur" data="40">' +
					'<item name="---" data="0"/>' +
				'</item>');
		*/

		protected static var _itemTypeXML_old:XMLList = new XMLList( '' +
			'<item name="Item" data="100">' +
				'<item name="Post" data="110"/>' +
				'<item name="Sign" data="120"/>' +
				'<item name="Sub-Sign" data="130"/>' +
			'</item>' +
			'<item name="Label" data="300">' +
				'<item name="Main Label" data="310"/>' +
				'<item name="Sub Label" data="320"/>' +
			'</item>' +
			'<item name="Info" data="200">' +
				'<item name="Photo" data="210"/>' +
				'<item name="Panorama" data="220"/>' +
				'<item name="Surface Change" data="230"/>' +
			'</item>');

		public static var ACTION_CREATE:int		= 0;	//	*
		public static var ACTION_ADD:int		= 5;	//	*
		public static var ACTION_EDIT:int		= 10;	//	*
		public static var ACTION_CHECK:int		= 20;	//	*
		public static var ACTION_MARK:int		= 30;	//	*
		public static var ACTION_ORDER:int		= 40;	//
		public static var ACTION_DELETE:int		= 90;	//	*
		public static var ACTION_DOCUMENT:int	= 100;	//	*

		protected static var _actionMap:Dictionary;
		protected static var _actionList:ArrayCollection;
		protected static var _actionBaseList:ArrayCollection = new ArrayCollection( new Array( 
																{ data:ACTION_DOCUMENT,	label:'Dokumentieren',	short:'doc',	col:0xa0a0e0,	enabled:true },
																{ data:ACTION_CREATE,	label:'Neu',			short:'new',	col:0x808080,	enabled:true },	//
																{ data:ACTION_ADD,		label:'Bestand',		short:'est',	col:0x808080,	enabled:true },	//
																{ data:ACTION_EDIT,		label:'Bearbeiten',		short:'edi',	col:0x8080c0,	enabled:false },
																{ data:ACTION_CHECK,	label:'Überprüfen',		short:'chk',	col:0x80e080,	enabled:true },	//
																{ data:ACTION_MARK,		label:'Markieren',		short:'mrk',	col:0x8080e0,	enabled:true}, 
																{ data:ACTION_ORDER,	label:'Bestellen',		short:'rdr',	col:0x80c080,	enabled:true},	// 
																{ data:ACTION_DELETE,	label:'Löschen',		short:'del',	col:0xe0e0e0,	enabled:true }	//
																));


		public static var STATUS_NULL:int		= -10000;
		public static var STATUS_FORCEINIT:int	= -100;
		public static var STATUS_UNDEF:int		= -2;
//		public static var STATUS_UNSET:int		= -1;
		public static var STATUS_NOP:int		= -1;	//	*
		public static var STATUS_OK:int			= 0;	//	*
//		public static var STATUS_FRSH:int		= 5;
//		public static var STATUS_MAPPED:int		= 10;
		public static var STATUS_NOTE:int		= 10;
		public static var STATUS_PLANNING:int	= 15;	//	*
		public static var STATUS_PLANNED:int	= 20;	//	*
		public static var STATUS_ACCEPTED:int	= 30;	//	*
		public static var STATUS_DELIVERED:int	= 40;	//	*
		public static var STATUS_INSTALLED:int	= 50;	//	*
		public static var STATUS_CLARIFY:int	= 60;	//	*
		public static var STATUS_DELAYED:int	= 65;	//	*
		public static var STATUS_MISSING:int	= 70;	//	*
		public static var STATUS_ERROR:int		= 100;	//	*
		public static var STATUS_DELETED:int	= 200;	//	*
		public static var STATUS_SELECTED:int	= 1000;

		protected static var _statusMap:Dictionary;
		protected static var _statusList:ArrayCollection;
		protected static var _statusBaseList:ArrayCollection = new ArrayCollection( new Array(
																{ data:STATUS_NULL,			label:'---',					short:'???',	col:0xc0c0c0,	enabled:false },	// 
																{ data:STATUS_OK,			label:'OK',						short:'ok',		col:0x80ff80,	enabled:true },	// 
																{ data:STATUS_ERROR,		label:'Beanstandung',			short:'err',	col:0xf08080,	enabled:true },	//
//																{ data:STATUS_MISSING,		label:'fehlt',					short:'miss',	col:0xc08080,	enabled:false },
																{ data:STATUS_DELAYED,		label:'zurückgestellt',			short:'dely',	col:0x8080e0,	enabled:true }, //
																{ data:STATUS_PLANNING,		label:'in Planung',				short:'plng',	col:0xb0b0f0,	enabled:true },	//
																{ data:STATUS_PLANNED,		label:'geplant',				short:'plnd',	col:0xb0b0ff,	enabled:true }, //
																{ data:STATUS_ACCEPTED,		label:'freigegeben',			short:'acc',	col:0x80c080,	enabled:false },
																{ data:STATUS_DELIVERED,	label:'geliefert',				short:'dlvd',	col:0x8080e0,	enabled:false },
																{ data:STATUS_INSTALLED,	label:'installiert',			short:'inst',	col:0x8080f0,	enabled:true },	//
																{ data:STATUS_CLARIFY,		label:'Klärung erforderlich',	short:'tbc',	col:0x8080f0,	enabled:true },	// 
																{ data:STATUS_NOTE,			label:'Hinweis',				short:'note',	col:0xc08080,	enabled:true },
																{ data:STATUS_DELETED,		label:'gelöscht',				short:'del',	col:0xe0e0e0,	enabled:true }, //
																{ data:STATUS_NOP,			label:'keine Änderung',			short:'nop',	col:0xe0e0e0,	enabled:true }	//
																));
		
//		public static var relevantStatusCodeIds:Array = [ STATUS_OK, STATUS_ERROR, STATUS_MISSING, STATUS_PLANNING, STATUS_PLANNED, STATUS_DELETED];
		public static var relevantStatusCodeIds:Array = [ STATUS_OK, STATUS_ERROR, STATUS_MISSING, STATUS_DELAYED, STATUS_PLANNING, STATUS_PLANNED, STATUS_ACCEPTED, STATUS_DELIVERED, STATUS_INSTALLED, STATUS_CLARIFY, STATUS_NOTE, STATUS_DELETED];
		public static var viewStatusCodeIds:Array = [ STATUS_OK, STATUS_ERROR, STATUS_MISSING, STATUS_DELAYED, STATUS_PLANNING, STATUS_PLANNED, STATUS_ACCEPTED, STATUS_DELIVERED, STATUS_INSTALLED, STATUS_CLARIFY, STATUS_NOTE, STATUS_DELETED];
		
		protected static var _locationTypeList:ArrayCollection = new ArrayCollection( new Array( 
																		{ data:100, label:"Item"},
																		{ data:200, label:"Info"}
																	));
/*		
		c.i) nicht bearbeitet
		c.ii) kartiert
		c.iii) Nr., Lage
		c.iv) in Planung
		c.v) Planung fertig
		c.vi) Freigabe
		c.vii) bestellt
		c.viii) geliefert
		c.ix) montiert
		c.x) zurückgestellt
		c.xi) Klärung erforderlich
		c.xii) Mangel (automatische Zuordnung, wenn dies in App gewählt wird)
		c.xiii) OK (automatische Zuordnung, wenn dies in App gewählt wird)
*/		
		public static var USER_UNCONFIRMED:int	= -1;
		public static var USER_VIEW:int			= 0;
		public static var USER_EDIT:int			= 50;
		public static var USER_ADMIN:int		= 100;

		protected static var _userTypeMap:Object = { 0:'unconfirmed', 10:'Guest', 50:'Editor', 100:'Admin' };

		protected static var _directionMap:Dictionary;
		protected static var _directionList:ArrayCollection = new ArrayCollection( new Array( 
																	{ data:0, label:'-' }, 
																	{ data:1, label:'geradeaus' }, 
																	{ data:2, label:'links' },
																	{ data:3, label:'rechts' },
																	{ data:4, label:'Kurve links' }, 
																	{ data:5, label:'Kurve rechts' },
																	{ data:6, label:'Schlenker links' },
																	{ data:7, label:'Schlenker rechts' },
																	{ data:8, label:'links-rechts' },
																	{ data:9, label:'schräg rechts' },
																	{ data:10, label:'schräg links' },
																	{ data:11, label:'im KV geradeaus' },
																	{ data:12, label:'im KV links' },
																	{ data:13, label:'im KV rechts'}
																	));

		protected static var _positionMap:Dictionary;
		protected static var _positionList:ArrayCollection = new ArrayCollection( new Array(
																	{ data:-1, label:'---'},
																	{ data:0, label:'N'},
																	{ data:45, label:'NO'}, 
																	{ data:90, label:'O'}, 
																	{ data:135, label:'SO'}, 
																	{ data:180, label:'S'}, 
																	{ data:225, label:'SW'}, 
																	{ data:270, label:'W'}, 
																	{ data:315, label:'NW'}, 
																	{ data:-360, label:'N-S'},
																	{ data:-90, label:'O-W'}, 
																	{ data:-45, label:'NO-SW'}, 
																	{ data:-315, label:'NW-SO'}
																	/*
																	{ data:-45, label:'NO-SW'}, 
																	{ data:-90, label:'O-W'}, 
																	{ data:-135, label:'SO-NW'}, 
																	{ data:-180, label:'S-N'}, 
																	{ data:-225, label:'SW-NO'}, 
																	{ data:-270, label:'W-O'}, 
																	{ data:-315, label:'NW-SO'}, 
																	{ data:-360, label:'N-S' }*/
																	));
		
		public static var ICON_FILTER_ALL:int		= -1;
		public static var ICON_FILTER_ARROWTIPS:int	= 0x40;
		public static var ICON_FILTER_ASDESCEND:int	= 0x20;
		public static var ICON_FILTER_SPECIAL:int	= 0x28;
		public static var ICON_FILTER_DIRECTIONS:int= 0x05;
		public static var ICON_FILTER_BIKE:int		= 0x50;
		public static var ICON_FILTER_WALK:int		= 0x60;
		public static var ICON_FILTER_REGIO:int		= 0x70;
		public static var ICON_FILTER_ROUTEN:int	= 0x80;
		public static var ICON_FILTER_SPORT:int		= 0x90;
		
		public static var ICON_LINK_LARGE:int		= 5;

		public static var ICON_LINK_A1:int			= 0x10;
		public static var ICON_LINK_A2:int			= 0x12;
		public static var ICON_LINK_A3:int			= 0x14;
		public static var ICON_LINK_A4:int			= 0x16;

		public static var ICON_LINK_B1:int			= 0x20;
		public static var ICON_LINK_B2:int			= 0x22;

		public static var ICON_LINK_ARROWTIP:int	= 0x30;
		
		protected static var style_def:SymbolStyle;
		protected static var style_fresh:SymbolStyle;
		protected static var style_ok:SymbolStyle;
		protected static var style_planning:SymbolStyle;
		protected static var style_process:SymbolStyle;
		protected static var style_delay:SymbolStyle;
		protected static var style_error:SymbolStyle;
		protected static var style_deleted:SymbolStyle;
		protected static var style_selected:SymbolStyle;

		protected static var _iconCacheValid:Boolean = false;
		protected static var _iconCacheLoading:Boolean = false;
		protected static var _iconList:ArrayCollection;
		protected static var _iconIdMap:Dictionary;

		protected static var _tagCacheValid:Boolean = false;
		protected static var _tagCacheLoading:Boolean = false;
		protected static var _tagList:ArrayCollection;
		protected static var _tagIdMap:Dictionary;
		
		protected static var _ownerCacheValid:Boolean = false;
		protected static var _ownerCacheLoading:Boolean = false;
		protected static var _ownerList:ArrayCollection;
		protected static var _ownerIdMap:Dictionary;
		
		protected static var _projectCacheValid:Boolean = false;
		protected static var _projectCacheLoading:Boolean = false;
		protected static var _projectList:ArrayCollection;
		protected static var _projectIdMap:Dictionary;
		
		public function AppSettings() {
		}
		
		public static function get isDesktop():Boolean {
			if ( ! _platformDetected) {
				_platformDetected = true;
				_detectedPlatform = (Capabilities.version.substr(0,3).toLowerCase() == 'win');
			}
			return ( _forcePlatform ? _forceDesktop : _detectedPlatform);
		}
		
		public static function setUser( u:SignsUser):void {
			_user = u;
		}
		
		public static function getUser():SignsUser {
			if ( _user == null) {
				_user = new SignsUser({ id: 10, username:'mschorer', userlevel:AppSettings.USER_ADMIN, created:new Date()});
			}
			
			return _user;
		}
		
		//---------------------------------------------------------------------
		
		public static function get versionNumber():String {
			return _versionNumber;
		}
		
		public static function set versionNumber( vn:String):void {
			_versionNumber = vn;
		}
		
		//---------------------------------------------------------------------
		
		public static function get appBaseUrl():String {
			return _baseUrl;
		}
		
		public static function set appBaseUrl( burl:String):void {
			_baseUrl = burl;
		}
		
		public static function get uploadScriptUrl():String {
			return _baseUrl+_uploadScript;
		}
		
		public static function get uploadDBScriptUrl():String {
			return _baseUrl+_uploadDBScript;
		}
		
		public static function get imageRootPath():String {
			return _imageRootPath;
		}
		
		public static function get imageOffsetPath():String {
			return _imageOffsetPath;
		}

		public static function get localImagePath():String {
			return _localImagePath;
		}
		
		public static function get persistentStoragePath():String {
			return _persistentStoragePath;
		}
		
		public static function set persistentStoragePath( p:String):void {
			_persistentStoragePath = p;
			_persistentStorage = null;
		}
		
		public static function get persistantStorage():File {
			
			if ( _persistentStorage == null) {
				_persistentStorage = File.applicationStorageDirectory.resolvePath( persistentStoragePath);
				if ( ! _persistentStorage.exists) _persistentStorage.createDirectory();
			}
			
			return _persistentStorage;
		}
		
		public static function get databaseStoragePath():String {
			return _databaseStoragePath;
		}
		
		public static function set databaseStoragePath( p:String):void {
			_databaseStoragePath = p;
			_databaseStorage = null;
		}
		
		public static function get databaseStorage():File {
			
			if ( _databaseStorage == null) {
				_databaseStorage = File.applicationStorageDirectory.resolvePath( databaseStoragePath);
				if ( ! _databaseStorage.exists) _databaseStorage.createDirectory();
			}
			
			return _databaseStorage;
		}
		
		public static function set databaseImagePath( p:String):void {
			_dbImagePath = p;
		}
		
		public static function get databaseImagePath():String {
			return _dbImagePath;
		}
		
		//---------------------------------------------------------------------
		
		public static function get iconDownloadUrl():String {
			return _imageSizePath+'/'+_iconDownloadWidth+'/'+_iconDownloadHeight+'/'+_iconDownloadScaleup;
		}
		
		public static function get iconDownloadHeight():int {
			return _iconDownloadHeight;
		}		
		public static function get iconDownloadWidth():int {
			return _iconDownloadWidth;
		}
		public static function get iconDownloadScaleup():int {
			return _imageDownloadScaleup;
		}
		
		public static function get imageDownloadUrl():String {
			return _imageSizePath+'/'+_imageDownloadWidth+'/'+_imageDownloadHeight+'/'+_imageDownloadScaleup;
		}
		
		public static function get imageDownloadHeight():int {
			return _imageDownloadHeight;
		}
		public static function set imageDownloadHeight( w:int):void {
			_imageDownloadHeight = w;
		}

		public static function get imageDownloadWidth():int {
			return _imageDownloadWidth;
		}
		public static function set imageDownloadWidth( h:int):void {
			_imageDownloadWidth = h;
		}

		public static function get imageAccessOnline():Boolean {
			return _imageAccessOnline;
		}
		public static function set imageAccessOnline( b:Boolean):void {
			_imageAccessOnline = b;
		}
		
		public static function get imageDownloadScaleup():int {
			return _imageDownloadScaleup;
		}
		
		//---------------------------------------------------------------------
		
		public static function get online():Boolean {
			return _onlineMode;
		}
		
		public static function set online( m:Boolean):void {
			_onlineMode = m;
		}
		
		//---------------------------------------------------------------------
		
		public static function invalidateCaches():void {
			debug( "invalidate caches");
			invalidateIconCache();
			invalidateTagCache();
			invalidateOwnerCache();
			invalidateProjectCache();
		}
	
		public static function prepareSettings():void {
			debug( "prep settings");
			prepareIconList();
			prepareTagList();
			prepareOwnerList();
			prepareProjectList();
		}

		public static function checkSettingsReady():Boolean {
			if ( _iconCacheValid && _tagCacheValid && _ownerCacheValid && _projectCacheValid) {
				debug( "check READY.");

//				dispatchEvent( new TopEvent( TopEvent.SETTINGS_LOADED));
				
				return true;
			} else {
				debug( "check LOADING.");
				return false;
			}
		}
		
		public static function invalidateIconCache():void {
			_iconList.filterFunction = null;
			_iconList.refresh();
			_iconCacheValid = false;
			_iconList.removeAll();
		}

		protected static function prepareIconList():void {
			debug( "prep icons");
			_iconIdMap = new Dictionary();
			
			if ( _iconList == null) _iconList = new ArrayCollection();
			if ( _workingIcon == null) _workingIcon = new SignsIcon();
			_iconList.removeAll();
			
			_iconCacheLoading = true;
			
//			var unsel:SignsIcon = new SignsIcon( { cache_id:-1, name:'---', preview_url:null});
//			_iconList.addItemAt( unsel, 0);
			
			var icon:SignsIcon = new SignsIcon();
			var sp:RetrievalParameters = new RetrievalParameters( null, true, 'type desc, name ASC');

			//_iconList.addAll( icon.list( sp));
			
			var resp:Responder = null;
			if ( Model.asyncMode) resp = new Responder( asyncIcons, _workingIcon.defaultSqlErrorResponder);
			
			var ps:ArrayCollection = _workingIcon.list( sp, resp);
			
			if ( ps != null) {
				_iconList.addAll( ps);
				iconsDone();
			}
		}
		
		
		protected static function asyncIcons( sqe:SQLResult):void {
			var ul:ArrayCollection = _workingIcon.addResult( sqe, _iconList);
			
			if ( ul != null) iconsDone();
		}
		
		protected static function iconsDone():void {

			_iconCacheLoading = false;
			for( var i:int = 0; i < _iconList.length; i++) {
				var st:SignsIcon = _iconList.getItemAt( i) as SignsIcon;
				_iconIdMap[ st.cache_id] = i;
			}
			_iconCacheValid = true;
			
			checkSettingsReady();
		}
		
		public static function iconIndexById( id:int):int {
			if ( ! _iconCacheValid && ! _iconCacheLoading) prepareIconList();
			
			return _iconIdMap[ id] as int;
		}

		public static function get iconList():ArrayCollection {
			if ( ! _iconCacheValid && ! _iconCacheLoading) prepareIconList();
			
			return _iconList;
		}
		
		//---------------------
		
		public static function invalidateTagCache():void {
			_tagList.filterFunction = null;
			_tagList.refresh();
			_tagCacheValid = false;
			_tagList.removeAll();
		}

		protected static function prepareTagList():void {
			debug( "prep tags");
			_tagIdMap = new Dictionary();
			
			if ( _tagList == null) _tagList = new ArrayCollection();
			if ( _workingTag == null) _workingTag = new SignsTag();
			
			_tagList.removeAll();
			
			_tagCacheLoading = true;
			
//			var unsel:SignsTag = new SignsTag( { cache_id:-1, name:'---'});
//			_tagList.addItemAt( unsel, 0);
			
			var tag:SignsTag = new SignsTag();

			var sp:RetrievalParameters = new RetrievalParameters( null, true, 'parent_id asc, name ASC');
			
			var resp:Responder = null;
			if ( Model.asyncMode) resp = new Responder( asyncTags, _workingTag.defaultSqlErrorResponder);
			
			var ps:ArrayCollection = _workingTag.list( sp, resp);
			
			if ( ps != null) {
				_tagList.addAll( ps);
				tagsDone();
			}
		}
		
		
		protected static function asyncTags( sqe:SQLResult):void {
			var ul:ArrayCollection = _workingTag.addResult( sqe, _tagList);
			
			if ( ul != null) tagsDone();
		}
		
		protected static function tagsDone():void {
			_tagCacheLoading = false;
			
			for( var i:int = 0; i < _tagList.length; i++) {
				var st:SignsTag = _tagList.getItemAt( i) as SignsTag;
				_tagIdMap[ st.cache_id] = i;
			}
			_tagCacheValid = true;
			
			checkSettingsReady();
		}
		
		public static function tagIndexById( id:int):int {
			if ( ! _tagCacheValid && ! _tagCacheLoading) prepareTagList();
			
			return _tagIdMap[ id] as int;
		}
		
		public static function get tagList():ArrayCollection {
			if ( ! _tagCacheValid && ! _tagCacheLoading) prepareTagList();
			
			return _tagList;
		}

		//---------------------
		
		public static function invalidateOwnerCache():void {
			_ownerList.filterFunction = null;
			_ownerList.refresh();
			_ownerCacheValid = false;
			_ownerList.removeAll();
		}

		protected static function prepareOwnerList():void {
			debug( "prep owners");
			_ownerIdMap = new Dictionary();
			
//			if ( _ownerList == null) 
			if ( _ownerList == null) _ownerList = new ArrayCollection();
			if ( _workingOwner == null) _workingOwner = new SignsOwner();
			
			_ownerList.removeAll();
			
			_ownerCacheLoading = true;
			
//			var unsel:SignsOwner = new SignsOwner( { cache_id:-1, name:'---'});
//			_ownerList.addItemAt( unsel, 0);
			
			var sp:RetrievalParameters = new RetrievalParameters( null, true, 'name ASC');
			
			var resp:Responder = null;
			if ( Model.asyncMode) resp = new Responder( asyncOwners, _workingOwner.defaultSqlErrorResponder);
			
			var ps:ArrayCollection = _workingOwner.list( sp, resp);
			
			if ( ps != null) {
				_ownerList.addAll( ps);
				ownersDone();
			}
		}
		
		
		protected static function asyncOwners( sqe:SQLResult):void {
			var ul:ArrayCollection = _workingOwner.addResult( sqe, _ownerList);
			
			if ( ul != null) ownersDone();
		}
		
		protected static function ownersDone():void {
			_ownerCacheLoading = false;
			
			for( var i:int = 0; i < _ownerList.length; i++) {
				var st:SignsOwner = _ownerList.getItemAt( i) as SignsOwner;
				_ownerIdMap[ st.cache_id] = i;
			}
			_ownerCacheValid = true;
			
			checkSettingsReady();
		}
		
		public static function ownerIndexById( id:int):int {
			if ( ! _ownerCacheValid) prepareOwnerList();
			
			var idx:Object = _ownerIdMap[ id];
			
			return ( idx == null) ? -1 : (idx as int);
		}
		
		public static function ownerByIndex( id:int):SignsOwner {
			var owner:SignsOwner;
			
			if ( ! _ownerCacheValid) prepareOwnerList();
			
			try {
				owner = _ownerList.getItemAt( id) as SignsOwner;
			} catch( e:Error) {
				debug( "indexError retrieving owner");
			}
			
			return owner;
		}
		
		public static function get ownerList():ArrayCollection {
			if ( ! _ownerCacheValid && ! _ownerCacheLoading) prepareOwnerList();
			
			return _ownerList;
		}

		//---------------------
		
		public static function invalidateProjectCache():void {
			_projectList.filterFunction = null;
			_projectList.refresh();
			_projectCacheValid = false;
			_projectList.removeAll();
		}

		public static function prepareProjectList():void {
			debug( "prep projects");
			_projectIdMap = new Dictionary();
			
			if ( _projectList == null) _projectList = new ArrayCollection();
			if ( _workingProject == null) _workingProject = new SignsProject();
			_projectList.removeAll();
			
			_projectCacheLoading = true;
			
			//			var unsel:SignsOwner = new SignsOwner( { cache_id:-1, name:'---'});
			//			_ownerList.addItemAt( unsel, 0);
			
			var sp:RetrievalParameters = new RetrievalParameters( null, true, 'name ASC');
			
			var resp:Responder =null;
			if ( Model.asyncMode) resp = new Responder( asyncProjects, _workingProject.defaultSqlErrorResponder);
			
			var ps:ArrayCollection = _workingProject.list( sp, resp);
			
			if ( ps != null) {
				_projectList.addAll( ps);
				projectsDone();
			}
		}
		
		protected static function asyncProjects( sqe:SQLResult):void {
			var ul:ArrayCollection = _workingProject.addResult( sqe, _projectList);
			
			if ( ul != null) projectsDone();
		}
		
		protected static function projectsDone():void {
			_projectCacheLoading = false;
			
			for( var i:int = 0; i < _projectList.length; i++) {
				var st:SignsProject = _projectList.getItemAt( i) as SignsProject;
				_projectIdMap[ st.cache_id] = i;
			}
			_projectCacheValid = true;
			
			checkSettingsReady();
		}
		
		public static function projectIndexById( id:int):int {
			if ( ! _projectCacheValid && ! _projectCacheLoading) prepareProjectList();
			
			return _projectIdMap[ id] as int;
		}
		
		public static function get projectList():ArrayCollection {
			if ( ! _projectCacheValid && ! _projectCacheLoading) prepareProjectList();
			
			return _projectList;
		}
		
		//---------------------------------------------------------------------
		
		public static function get locationsTypes():ArrayCollection {
			return _locationTypeList;
		}
		
		public static function get itemTypeXML():XMLList {
			return _itemTypeXML;
		}
		
		public static function get itemFormatXML():XMLList {
			return _itemFormatXML;
		}
		
		public static function get itemLengthXML():XMLList {
			return _itemLengthXML;
		}
		
		public static function get itemConnectionXML():XMLList {
			return _itemConnectionXML;
		}
		
		public static function get actionEStatusXML():XMLList {
			return _eStatusXML;
		}
		
		//---------------------------------------------------------------------
		
		public static function getStyleForState( st:int):SymbolStyle {
			var style:SymbolStyle;
			
			if ( style_def == null) {
				style_def = new SymbolStyle();
				
				
				style_def.normal.line.color = 0xffffff;
				style_def.normal.line.width = 2;
				style_def.normal.surface.color = 0x8080ff;
				style_def.normal.surface.alpha = 0.7;
				
				style_def.selected.line.color = 0xffffff;
				style_def.selected.line.width = 2;
				style_def.selected.surface.color = 0xf02020;
				style_def.selected.surface.alpha = 0.9;
				
				style_def.icon.color = 0x0000ff;
				style_def.icon.alpha = 0.8;
				style_def.icon.scale = 1.0;
				style_def.icon.icon = 'Hexa';
			}

			switch( st) {
/*
				case AppSettings.STATUS_FRSH:
					if ( style_fresh == null) {
						style_fresh = style_def.clone();
						style_fresh.normal.surface.color = 0x80e080;
					}
					style = style_fresh;
					break;
*/
				case AppSettings.STATUS_OK:
					if ( style_ok == null) {
						style_ok = style_def.clone();
						style_ok.normal.line.color = 0x40c040;
						style_ok.normal.surface.color = 0x408040;
						style_ok.selected.line.color = 0x40f040;
						style_ok.selected.surface.color = 0x20c020;
					}
					style = style_ok;
					break;
				
				case AppSettings.STATUS_DELETED:
					if ( style_deleted == null) {
						style_deleted = style_def.clone();
						style_deleted.normal.line.color = 0xffffff;
						style_deleted.normal.surface.color = 0x404040;
						style_deleted.normal.line.color = 0xffffff;
						style_deleted.selected.surface.color = 0x808080;
					}
					style = style_deleted;
					break;

//				case AppSettings.STATUS_MAPPED:
				case AppSettings.STATUS_PLANNING:
				case AppSettings.STATUS_PLANNED:
					if ( style_planning == null) {
						style_planning = style_def.clone();
						style_planning.normal.line.color = 0x30c0c0;
						style_planning.normal.surface.color = 0x40ffff;
						style_planning.selected.line.color = 0x40e0e0;
						style_planning.selected.surface.color = 0x30c0c0;
					}
					style = style_planning;
					break;
				
				case AppSettings.STATUS_ACCEPTED:
//				case AppSettings.STATUS_ORDERED:
				case AppSettings.STATUS_DELIVERED:
				case AppSettings.STATUS_INSTALLED:
					if ( style_process == null) {
						style_process = style_def.clone();
						style_process.normal.surface.color = 0xff40ff;
						style_process.selected.surface.color = 0xc030c0;
					}
					style = style_process;
					break;
				
				case AppSettings.STATUS_DELAYED:
				case AppSettings.STATUS_CLARIFY:
					if ( style_delay == null) {
						style_delay = style_def.clone();
						style_delay.normal.surface.color = 0xf0f040;
					}
					style = style_delay;
					break;
				
				case AppSettings.STATUS_MISSING:
				case AppSettings.STATUS_ERROR:
					if ( style_error == null) {
						style_error = style_def.clone();
						style_error.normal.line.color = 0x800000;
						style_error.normal.surface.color = 0x800000;
						style_error.selected.line.color = 0xc00000;
						style_error.selected.surface.color = 0xc00000;
					}
					style = style_error;
					break;
				
				case AppSettings.STATUS_SELECTED:
					if ( style_selected == null) {
						style_selected = style_def.clone();
						style_selected.normal.surface.color = 0x606000;
						style_selected.normal.surface.alpha = 0.9;
						style_selected.selected.surface.color = 0x808000;
						style_selected.selected.surface.alpha = 0.9;
						style_selected.selected.line.width = 3;
					}
					style = style_selected;
					break;
				
				default:
					style = style_def;
			}

			return style;
		}
		
		//---------------------------------------------------------------------

		public static function set currentProject( p:SignsProject):void {
			_currentProject = p;
		}
		public static function get currentProject():SignsProject {
			return _currentProject;
		}		
		
		public static function getActionType( t:int):Object {
			if ( _actionMap == null) prepActions();

			return _actionMap[ t];
		}
		
		public static function getActions():ArrayCollection {
			if ( _actionList == null) prepActions();

			return _actionList;
		}
		
		protected static function prepActions():void {
			_actionMap = new Dictionary();
			_actionList = new ArrayCollection();
			for( var i:int = 0; i < _actionBaseList.length; i++) {
				var aObj:Object = _actionBaseList.getItemAt( i);
				_actionMap[ aObj.data] = aObj; 
				if ( aObj.enabled) _actionList.addItem( aObj);
			}
		}
		
		public static function getStatusType( t:int):Object {
			if ( _statusMap == null) prepStatus();

			return _statusMap[ t];
		}
		
		public static function getStatus():ArrayCollection {
			if ( _statusList == null) prepStatus();

			return _statusList;
		}
		
		protected static function prepStatus():void {
			_statusMap = new Dictionary();
			_statusList = new ArrayCollection();
			for( var i:int = 0; i < _statusBaseList.length; i++) {
				var aObj:Object = _statusBaseList.getItemAt( i);
				_statusMap[ aObj.data] = aObj; 
				if ( aObj.enabled) _statusList.addItem( aObj);
			}

		}
		
		public static function getUserType( t:int):String {
			var s:String = _userTypeMap[ t];
			
			return ( s == null) ? '-' : s;
		}
		
		public static function getDirectionType( t:int):Object {
			if ( _directionMap == null) {
				_directionMap = new Dictionary();
				for( var i:int = 0; i < _directionList.length; i++) {
					var aObj:Object = _directionList.getItemAt( i);
					_directionMap[ aObj.data] = aObj; 
				}
			}
			return _directionMap[ t];
		}
		
		public static function getDirections():ArrayCollection {
			return _directionList;
		}
		
		public static function _getCompassDirection( t:int):String {
			var o:Object = getDirectionType( t);
			
			return ( o == null) ? ('->'+t) : o.label;
		}
		
		public static function getPositionType( t:int):Object {
			if ( _positionMap == null) {
				_positionMap = new Dictionary();
				for( var i:int = 0; i < _positionList.length; i++) {
					var aObj:Object = _positionList.getItemAt( i);
					_positionMap[ aObj.data] = aObj; 
				}
			}
			return _positionMap[ t];
		}
		
		public static function getPositions():ArrayCollection {
			return _positionList;
		}
		
		public static function getPosition( t:int):String {
			var o:Object = getPositionType( t);
			
			return ( o == null) ? ('>'+t+'°') : o.label;
		}
		
		public static function set userMap( um:ArrayCollection):void {
			if ( _userMap == null) _userMap = new ArrayCollection();
			_userMap.removeAll();
			_userMap.addAll( um);
		}
/*
		public static function get userMap():ArrayCollection {
			return _userMap;
		}
*/		
		public static function getUserById( id:int):SignsUser {
			for each( var u:SignsUser in _userMap) {
				if ( u.id == id) return u;
			}
			
			return null;
		}
		
		public static function hashPassword( pwd:String):String {
			return MD5.hash( _securitySalt + pwd);
		}

		protected static function debug( txt:String):void {
			trace( "AppSettings: "+txt);
		}
	}
}