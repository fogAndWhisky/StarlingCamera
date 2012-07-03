package starling.extensions.camera
{
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.textures.Texture;

    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.geom.Matrix;

    /**
     * Just something to place onstage in front of the camera
     *
     * @author mtanenbaum
     */
    public class Wanderer extends Sprite
    {
        private static const RADIUS:Number = 50;
        private const SPEED:Number = 10;
        private const HALF_SPEED:Number = SPEED/2;

        /**
         * Class constructor
         */
        public function Wanderer()
        {
            var shape:Shape = new Shape();

            shape.graphics.beginFill(0xFF0000, .5);
            shape.graphics.drawCircle(0, 0, RADIUS);

            var matrix:Matrix = new Matrix(1,0,0,1,RADIUS,RADIUS);

            var bmd:BitmapData = new BitmapData(100, 100, true, 0x00FFFFFF);
            bmd.draw(shape, matrix);

            var texture:Texture = Texture.fromBitmapData(bmd);
            var image:Image = new Image(texture);
            addChild(image);

            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        }

        private function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onEnterFrame(event:Event):void
        {
            x += (Math.random() * SPEED) - HALF_SPEED;
            x = Math.max(0, x);
            x = Math.min(stage.stageWidth, x);

            y += (Math.random() * SPEED) - HALF_SPEED;
            y = Math.max(0, y);
            y = Math.min(stage.stageHeight, y);
        }
    }
}
