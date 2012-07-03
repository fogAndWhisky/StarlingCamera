package starling.extensions.camera
{
    import flash.geom.Rectangle;
    import starling.events.Event;
    import starling.display.Sprite;

    /**
     * This and Main provide a basic tutorial on how to use the StarlingCamera
     *
     * @author mtanenbaum
     */
    public class MainView extends Sprite
    {
        private var camera:StarlingCamera;

        public function MainView()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        private function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

            //Create a camera view
            camera = new StarlingCamera();

            //Initialize. Pass in:
            //1. a rect to define the camera "viewport"
            //2. a capture rate (fps, default 24)
            //3. a downsample value (.5 means half-height, half-width, default 1)
            //4. true if you want to rotate the camera (default false)
            camera.init(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), 8, .5, false);
            //Each time you call reflect() you toggle mirroring on/off
            camera.reflect();
            //Put it onstage
            addChild(camera);
            //Select a webcam
            camera.selectCamera(0);

            //And just to demonstrate that we're in Starling...
            //...animate the camera...
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            //...and sandwich it between two other display objects
            var w1:Wanderer = new Wanderer();
            addChildAt(w1, 0);
            var w2:Wanderer = new Wanderer();
            addChild(w2);
        }

        private var r:Number = 0;

        private function onEnterFrame(event:Event):void
        {
            r += .1;
            camera.y = Math.sin(r) * 100;
        }
    }
}
