package 
{
	import com.efnx.fps.fpsBox;
	import com.quietless.bitmap.BitmapSnapshot;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import org.libspark.flartoolkit.core.FLARCode;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.papervision3d.materials.BitmapMaterial;

	import org.libspark.flartoolkit.detector.FLARSingleMarkerDetector;
	import org.libspark.flartoolkit.support.pv3d.FLARCamera3D
	
	import org.libspark.flartoolkit.support.pv3d.FLARBaseNode;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	
	import com.adobe.images.JPGEncoder;
	
	import com.dd.screencapture.ScreenCapture;
	import com.dd.screencapture.SimpleFlvWriter;
	
	import flash.filters.*;
	
	/**
	 * ...
	 * @author Ian Icasiano
	*/

	[SWF(width = "640", height = "480", frameRate = "30", backgroundColor = "#FFFFFF")]
	
	public class Main extends Sprite 
	{
		[Embed(source="summitdigitalsmall.pat", mimeType = "application/octet-stream")]
		private var gePattern:Class;
		
		[Embed(source="camera_para.dat", mimeType = "application/octet-stream")]
		private var params:Class;
		
		[Embed(source = "summit_digital_logo_red.jpg")] 
		private var CubeTexture:Class;
		
		private var fParams:FLARParam;
		private var mPattern:FLARCode;
		private var vid:Video;
		private var cam:Camera;
		private var bmd:BitmapData;
		
		private var raster:FLARRgbRaster_BitmapData;
		private var detector:FLARSingleMarkerDetector;
		
		private var scene:Scene3D;
		private var flarCamera:FLARCamera3D;
		private var container:FLARBaseNode;
		private var vp:Viewport3D;
		private var bre:BasicRenderEngine;
		
		private var screenshotBitmap:BitmapData;
		
		private var trans:FLARTransMatResult;
		private var snapshotBTN:SnapshotMC;
		private var recordBTN:RecordBtn;
		private var uploadScript:String = "http://www.entrepreneur.com.ph/objects/areality/upload.php";
		private var uploadVideoScript:String = "http://www.entrepreneur.com.ph/objects/areality/uploadVideo.php";
		private var uploadDir:String = "images";
		private var imageNamePNG:String = "FlashAugmentedRealitySnapshot.jpg";
		private var vidNameFLV:String = "FlashAugmentedRealityRecord.flv";
		private var debugMode:Boolean = false;
		public static var textBox:TextField;
		private var isRecording:Boolean = false;
		
		private var screenCapture:ScreenCapture;
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);	
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			//stage.scaleMode = StageScaleMode.NO_SCALE;
			//stage.align = StageAlign.TOP_LEFT;
			var aaa:aa = new aa();
			//watermark = new SummitDigitalWatermark();
			aaa.x = 470;
			aaa.y = 310;
			
			setupFLAR();
			setupCamera();
			setupBitmap();
			setupPV3D();
			addEventListener (Event.ENTER_FRAME, loop);
			createButton();
			setupScreenCapture();
			if (debugMode) {
				Main.textBox = new TextField();
				Main.textBox.y = 200;
				addChild(textBox);
				var fps:fpsBox = new fpsBox(stage);
				addChild(fps);
			}
			

			addChild(aaa);
			
		}
		private function setupScreenCapture():void {
			screenCapture = ScreenCapture.getInstance();
			screenCapture.source = stage;
			screenCapture.fps = 10;
			screenCapture.size( 640, 480);
			screenCapture.x = 0;
			screenCapture.y = 0;
			stage.addChild( screenCapture );
		}
		private function loop(e:Event):void 
		{
			bmd.draw (vid);
			try {
				if (detector.detectMarkerLite(raster, 80) && detector.getConfidence() > 0.5 ) 
				{
					detector.getTransformMatrix(trans);
					container.setTransformMatrix(trans);
					bre.renderScene(scene, flarCamera, vp);
				}
			}catch (e:Error) {
				
			}
		}
		private function setupPV3D():void 
		{
			scene = new Scene3D();
			flarCamera = new org.libspark.flartoolkit.support.pv3d.FLARCamera3D(fParams);
			container = new FLARBaseNode();
			scene.addChild(container);
			
			var pl:PointLight3D = new PointLight3D();
			pl.x = 1000;
			pl.y = 1000;
			pl.z = 1000;
			var cubeTexture:Bitmap = new CubeTexture() as Bitmap;
			
			var ml:MaterialsList = new MaterialsList( { all: new FlatShadeMaterial(pl) } );
			ml.addMaterial( new BitmapMaterial(cubeTexture.bitmapData), "all");
			var cube1:Cube = new Cube(ml, 30, 30 , 30);
			var cube2:Cube = new Cube(ml, 30, 30 , 30);
			cube2.z = 50;
			var cube3:Cube = new Cube(ml, 30, 30 , 30);
			cube3.z = 100;
			container.addChild(cube1);
			container.addChild(cube2);
			container.addChild(cube3);
			
			bre = new BasicRenderEngine();
			trans = new FLARTransMatResult();
			
			vp = new Viewport3D();
			addChild(vp);
		}
		private function setupCamera():void 
		{
			vid = new Video (640, 480);
			cam = Camera.getCamera();
			cam.setMode (640, 480, 30);
			vid.attachCamera(cam);
			addChild(vid);
		}
		private function setupFLAR():void {
			fParams = new FLARParam();
			fParams.loadARParam(new params() as ByteArray);
		
			mPattern = new FLARCode(16, 16);
			mPattern.loadARPatt(new gePattern());
		}
		private function setupBitmap():void 
		{
			bmd = new BitmapData(640, 480);
			bmd.draw(vid);
			raster = new FLARRgbRaster_BitmapData(bmd);
			detector = new FLARSingleMarkerDetector(fParams, mPattern, 80);
		}
		private function createSnapShot(e:MouseEvent = null):void {
			
			snapshotBTN.visible = false;
			recordBTN.visible = false;
			var img:BitmapSnapshot = new BitmapSnapshot(stage, imageNamePNG, 640, 480);
			//img.saveToDesktop();	
			img.saveOnServer(uploadScript, uploadDir);
			snapshotBTN.visible = true;
			recordBTN.visible = true;
		}
		
		private function createButton():void
		{
			
			snapshotBTN = new SnapshotMC();
			snapshotBTN.mouseChildren = false;
			snapshotBTN.addEventListener(MouseEvent.CLICK, createSnapShot);
			snapshotBTN.buttonMode = true;
			addChild(snapshotBTN);
			recordBTN = new RecordBtn();
			recordBTN.mouseChildren = false;
			recordBTN.addEventListener(MouseEvent.CLICK, recordBTNHandler);
			recordBTN.buttonMode = true;
			recordBTN.label_txt.text = "record";
			recordBTN.x = stage.stageWidth - recordBTN.width;
			addChild(recordBTN);
			
		}
		private function recordBTNHandler(e:MouseEvent = null):void {
			if (recordBTN.label_txt.text == "record") {
				recordBTN.label_txt.text = "stop";
				screenCapture.record();
				isRecording = true;
			}else if (recordBTN.label_txt.text == "stop") {
				recordBTN.label_txt.text = "save";
				screenCapture.stop();
				isRecording = false;
			}else if (recordBTN.label_txt.text == "save") {
				
				//var saveFile:FileReference = new FileReference();
				//saveFile.save( screenCapture.data, "video.flv" );
				saveOnServer(uploadVideoScript);
				recordBTN.label_txt.text = "please wait";
			}
		}
		private function saveOnServer($script:String):void
		{	
			var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/octet-stream");
			var req:URLRequest = new URLRequest($script+'?filename='+vidNameFLV);
				req.requestHeaders.push(hdr);
				req.data = screenCapture.data;				
				req.method = URLRequestMethod.POST;			
			
            var ldr:URLLoader = new URLLoader();
                ldr.dataFormat = URLLoaderDataFormat.BINARY;
                ldr.addEventListener(Event.COMPLETE, onRequestComplete);
                ldr.addEventListener(IOErrorEvent.IO_ERROR, onRequestFailure);
                ldr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityViolation);	
          		ldr.load(req);
		}
		private function onRequestComplete(e:Event):void
		{
			//log('Upload of ' + _name + ' was successful');
			//Main.textBox.appendText('Upload was successful');
			//ExternalInterface.call("loadSnapShot");
			recordBTN.label_txt.text = "success";
		}	
		
		private function onRequestFailure(e:IOErrorEvent):void
		{
			//log('Upload of '+_name+' has failed');
			//Main.textBox.appendText('Upload has failed');
			recordBTN.label_txt.text = "failed";
		}	
		
		
		private function onSecurityViolation(e:SecurityErrorEvent):void
		{
			//log('Security Violation has occurred, check crossdomain policy files');
			//Main.textBox.appendText('Security Violation has occurred, check crossdomain policy files');
			recordBTN.label_txt.text = "failed";
		}

	}
}