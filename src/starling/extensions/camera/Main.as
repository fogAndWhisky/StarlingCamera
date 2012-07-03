package starling.extensions.camera
{
    import flash.events.Event;
    import starling.core.Starling;
    import flash.display.Sprite;

    /**
     * This and the MainView provide a basic tutorial on how to use the StarlingCamera
     *
     * @author mtanenbaum
     */

    [SWF(width="550", height="400", frameRate="30", backgroundColor="#1199EF")]
    public class Main extends Sprite
    {
        public function Main()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        private function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

            //Init Starling
            Starling.handleLostContext = true;
            var starling:Starling = new Starling(MainView, stage);
            starling.antiAliasing = 1;
            starling.start();
        }
    }
}
