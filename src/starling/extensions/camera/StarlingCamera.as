package starling.extensions.camera
{
    import starling.display.Sprite;
    import starling.display.Image;
    import starling.textures.Texture;

    import flash.display.BitmapData;
    import flash.display3D.textures.Texture;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.media.Camera;
    import flash.media.Video;

    /**
     * Handles the display of a camera in Starling
     *
     * @author mtanenbaum
     *
     * @internal
     * Argonaut is released under the MIT License
     * Copyright (C) 2012, Marc Tanenbaum
     *
     * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
     * files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
     * modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
     * Software is furnished to do so, subject to the following conditions:
     *
     * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
     *
     * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
     * WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
     * OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
     * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
     */
    public class StarlingCamera extends Sprite
    {
        /** Minimum allowable downsample size */
        private static const DOWNSAMPLE_MIN:Number = 0.001;

        /** Maximum frame rate (not acutally enforced, just generates a warning) */
        private static const MAX_FRAME_RATE:int = 99;

        //Native
        private var camera:Camera;
        private var video:Video;
        private var bmd:BitmapData;

        //Starling
        private var image:Image;

        //Configs
        private var screenRect:Rectangle;
        private var fps:uint = 24;
        private var downSample:Number = 1;
        private var rotate:Boolean = false;
        private var matrix:Matrix;
        private var _mirror:Boolean = false;

        /**
         * Class constructor
         */
        public function CameraView()
        {
        }

        /**
         * Set up the capture parameters
         *
         * @param screenRect The "viewport" for the camera
         * @param fps		 A uint 0-n for the camera speed. Lower fps will of course improve performance
         * @param downSample A value >0 && <=1 for reducing the size of the image. Can drastically improve performance at the cost of image quality
         * @param rotate	 Fix for bug on Air for IOS/Android. Set to true when on these platforms to correct rotation
         */
        public function init(screenRect:Rectangle, fps:uint = 24, downSample:Number = 1, rotate:Boolean = false):void
        {
            trace("CameraView in rotate mode", rotate);

            this.screenRect = screenRect;
            this.fps = fps;
            if (fps == 0)
            {
                trace("WARNING::You're setting camera fps to 0. That's kinda lame.");
            }
            else if (fps > MAX_FRAME_RATE)
            {
                trace("WARNING::You're setting camera fps to", fps, "which is processor-intensive and probably too high to be useful.");
            }

            //Clamp the downsample between .1% and 1
            this.downSample = Math.max(DOWNSAMPLE_MIN, downSample);
            this.downSample = Math.min(1, this.downSample);

            this.rotate = rotate;

            matrix = new Matrix();
            matrix.scale(downSample, downSample);
            if (_mirror)
            {
                matrix.a *= -1;
                matrix.tx = (matrix.tx == 0) ? screenRect.width : 0;
            }

            if (rotate)
            {
               matrix.rotate(Math.PI/2);
            }
        }

        /**
         * Stop updates
         */
        public function shutdown():void
        {
            video.removeEventListener(Event.ENTER_FRAME, onVideoUpdate);
        }

        /**
         * Pick a camera by id
         */
        public function selectCamera(cameraId:uint):void
        {
            if (video)
            {
                video.attachCamera(null);
                video.removeEventListener(Event.ENTER_FRAME, onVideoUpdate);
                camera = null;
            }

            camera = Camera.getCamera(cameraId.toString());
            if (camera)
            {
                camera.setMode(screenRect.height, screenRect.width, fps);
                if (rotate)
                {
                    video = new Video(screenRect.height, screenRect.width);
                }
                else
                {
                     video = new Video(screenRect.width, screenRect.height);
                }
                video.attachCamera(camera);

                bmd = new BitmapData(screenRect.width * downSample, screenRect.height * downSample);

                video.addEventListener(Event.ENTER_FRAME, onVideoUpdate);
                var texture:starling.textures.Texture = starling.textures.Texture.fromBitmapData(bmd, false, false, downSample);
                image = new Image(texture);

                addChild(image);
            }
            else
            {
                trace("couldn't find camera", cameraId, "among cameras", Camera.names);
            }
        }

        /**
         * Toggle the camera between reflecting & not
         *
         * Mirorring is false by default, so if you want it on, call this method directly after <code>init()</code>
         */
        public function reflect():void
        {
            _mirror = !_mirror;
            if (matrix)
            {
                matrix.a *= -1;
                matrix.tx = (_mirror) ? (screenRect.width * downSample) : 0;
            }
        }

        /**
         * Get the current reflection setting
         */
        public function get mirror():Boolean
        {
            return _mirror;
        }

        /**
         * Retrieve a still from the camera
         *
         * This method doesn't downsample, so your image is full resolution
         *
         * @return a BitmapData snapshot from the camera
         */
        public function getImage():BitmapData
        {
            var retv:BitmapData = new BitmapData(screenRect.width, screenRect.height);
            var m:Matrix = matrix.clone();
            m.scale(1/downSample, 1/downSample);

            retv.draw(video, m);
            return retv;
        }

        /**
         * Draw to the GPU every frame
         */
        private function onVideoUpdate(event:*):void
        {
           bmd.draw(video, matrix);
           flash.display3D.textures.Texture(image.texture.base).uploadFromBitmapData(bmd);
        }
    }
}