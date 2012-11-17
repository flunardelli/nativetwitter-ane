package {
    import com.palDeveloppers.ane.NativeTwitter;
    import com.palDeveloppers.ane.TweetCompositionResult;
    import flash.desktop.NativeApplication;
    import flash.events.Event;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.text.StageText;
    import flash.text.StageTextInitOptions;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;

    /**
     * ...
     * @author JFM/HBE/DPP
     */
    public class Main extends Sprite {
        
        private var logField:StageText;
        
        private var tweetMessage:StageText;
        private var tweetUrl:StageText;
        private var tweetImg:StageText;
        
        private var requestResource:StageText;
        private var requestParams:StageText;
        
        public function Main():void {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.addEventListener(Event.RESIZE, stage_resizeHandler);
            
            // touch or gesture?
            Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
            
            // entry point
            
            logField = new StageText(new StageTextInitOptions(true));
            logField.editable = false;
            logField.stage = this.stage;
            logField.viewPort = new Rectangle(0, 340, stage.stageWidth - 20, 139);
            
            graphics.lineStyle(1, 0);
            graphics.drawRect(0, 340, stage.stageWidth - 20, 139);
            
            if (NativeTwitter.isSupported()) {
                graphics.beginFill(0x55FFFF);
                
                var isSetupButton:Sprite = getButton("Is Setup?");
                isSetupButton.addEventListener(MouseEvent.CLICK, isSetupButton_clickHandler);
                
                var getTwitterUsernameButton:Sprite = getButton("Get Usernames");
                getTwitterUsernameButton.addEventListener(MouseEvent.CLICK, getTwitterUsernameButton_clickHandler);
                getTwitterUsernameButton.x = 170;
                
                var tweetButton:Sprite = getButton("Compose tweet");
                tweetButton.addEventListener(MouseEvent.CLICK, tweetButton_clickHandler);
                tweetButton.y = 85;
                
                graphics.drawRect(170, 85, 150, 20);
                
                tweetMessage = new StageText();
                tweetMessage.editable = true;
                tweetMessage.text = "Hello from NativeTwitter ANE";
                tweetMessage.stage = this.stage;
                tweetMessage.viewPort = new Rectangle(170, 85, 150, 20);
                
                graphics.drawRect(170, 110, 150, 20);
                
                tweetUrl = new StageText();
                tweetUrl.editable = true;
                tweetUrl.text = "http://www.paldeveloppers.com";
                tweetUrl.stage = this.stage;
                tweetUrl.viewPort = new Rectangle(170, 110, 150, 20);
                
                graphics.drawRect(170, 135, 150, 20);
                
                tweetImg = new StageText();
                tweetImg.editable = true;
                tweetImg.text = "https://ma.twimg.com/profile_images/2366553916/7mknc11v28rx6od4dode_normal.jpeg";
                tweetImg.stage = this.stage;
                tweetImg.viewPort = new Rectangle(170, 135, 150, 20);
                
                var getPublicTimelineButton:Sprite = getButton("Get Home Timeline");
                getPublicTimelineButton.addEventListener(MouseEvent.CLICK, getHomeTimelineButton_clickHandler);
                getPublicTimelineButton.y = 170;
                
                var getMentionsButton:Sprite = getButton("Get Mentions");
                getMentionsButton.addEventListener(MouseEvent.CLICK, getMentionsButton_clickHandler);
                getMentionsButton.y = 170;
                getMentionsButton.x = 170;
                
                var twRequestButton:Sprite = getButton("Get TW Request");
                twRequestButton.addEventListener(MouseEvent.CLICK, twRequestButton_clickHandler);
                twRequestButton.y = 255;
                
                graphics.drawRect(170, 255, 150, 20);
                
                requestResource = new StageText();
                requestResource.editable = true;
                requestResource.text = "statuses/home_timeline.json";
                requestResource.stage = this.stage;
                requestResource.viewPort = new Rectangle(170, 255, 150, 20);
                
                graphics.drawRect(170, 280, 150, 20);
                
                requestParams = new StageText();
                requestParams.editable = true;
                requestParams.text = "{\"count\":\"1\"}";
                requestParams.stage = this.stage;
                requestParams.viewPort = new Rectangle(170, 280, 150, 20);
                
                graphics.endFill();
                
                addChild(isSetupButton);
                addChild(tweetButton);
                addChild(getTwitterUsernameButton);
                addChild(getPublicTimelineButton);
                addChild(getMentionsButton);
                addChild(twRequestButton);
                
                NativeTwitter.instance.accessDenied = accessDenied;
                NativeTwitter.instance.nonexistentAccount = nonexistentAccount;
                NativeTwitter.instance.twRequestResult = twRequestResult;
                NativeTwitter.instance.tweetComposed = tweetComposed;
                NativeTwitter.instance.homeTimelineRequested = homeTimelineGot;
                NativeTwitter.instance.twitterUsernamesGot = userNamesGot;
                NativeTwitter.instance.mentionsRequested = mentionsRequested;
            } else {
                log("NativeTwitter not supported by this platform");
            }
        }
        
        private function stage_resizeHandler(e:Event):void {
            logField.viewPort = new Rectangle(0, 340, stage.stageWidth - 20, 139);
        }
        
        private function isSetupButton_clickHandler(e:MouseEvent):void {
            log("isSetup: " + NativeTwitter.instance.isTwitterSetup());
        }
        
        private function twRequestButton_clickHandler(e:MouseEvent):void {
            try {
                var resource:String = requestResource.text;
                var params:Object = requestParams.text == "" ? null : JSON.parse(requestParams.text);
                NativeTwitter.instance.getTWRequest(resource, params);
            } catch (e:*) {
                log("Error, review your values");
            }
        }
        
        private function getMentionsButton_clickHandler(e:MouseEvent):void {
            NativeTwitter.instance.getMentions();
        }
        
        private function tweetButton_clickHandler(e:MouseEvent):void {
            var msg:String = tweetMessage.text;
            var url:String = tweetUrl.text == "" ? null : tweetUrl.text;
            var img:String = tweetImg.text == "" ? null : tweetImg.text;
            NativeTwitter.instance.composeTweet(msg, img, url);
        }
        
        private function getTwitterUsernameButton_clickHandler(e:MouseEvent):void {
            NativeTwitter.instance.getTwitterUsernames();
        }
        
        private function getHomeTimelineButton_clickHandler(e:MouseEvent):void {
            NativeTwitter.instance.getHomeTimeLine();
        }
        
        private function tweetComposed(resultCode:int):void {
            if ((resultCode & TweetCompositionResult.LONG_TEXT) == TweetCompositionResult.LONG_TEXT) {
                log("Tweet text too long");
            } else if ((resultCode & TweetCompositionResult.BAD_IMAGE) == TweetCompositionResult.BAD_IMAGE) {
                log("Problem attaching image");
            } else if ((resultCode & TweetCompositionResult.LONG_URL) == TweetCompositionResult.LONG_URL) {
                log("Attached URL too long");
            } else if ((resultCode & TweetCompositionResult.CANCELLED) == TweetCompositionResult.CANCELLED) {
                log("Cancelled tweet composition");
            } else {
                log("Tweet sent");
            }
        }
        
        private function userNamesGot(names:Vector.<String>):void {
            log("Registered names: " + names);
        }
        
        private function homeTimelineGot(resultCode:String, data:Object):void {
            var dataS:String = "";
            if (data != null)
                dataS = JSON.stringify(data);
            log("Home Timeline: " + resultCode + " - " + dataS);
        }
        
        private function mentionsRequested(resultCode:String, data:Object):void {
            var dataS:String = "";
            if (data != null)
                dataS = JSON.stringify(data);
            log("Mentions: " + resultCode + " - " + dataS);
        }
        
        private function accessDenied(requestName:String):void {
            log("Access Denied while requesting: " + requestName);
        }
        
        private function nonexistentAccount(accountId:int):void {
            log("Account with id " + accountId + " does not exist");
        }
        
        private function twRequestResult(resultCode:String, data:Object):void {
            var dataS:String = "";
            if (data != null)
                dataS = JSON.stringify(data);
            
            if (resultCode == "-1") log("\tEnsure custom params are correctly formatted");
            log("TWRequest: " + resultCode + " - " + dataS);
        }
        
        private function getButton(text:String):Sprite {
            var s:Sprite = new Sprite();
            s.graphics.beginFill(0);
            s.graphics.drawRect(0, 0, 150, 75);
            s.graphics.endFill();
            s.mouseChildren = false;
            
            var t:TextField = new TextField();
            t.textColor = 0xFFFFFF;
            t.defaultTextFormat = new TextFormat("_sans", 15);
            t.x = 25;
            t.y = 27;
            t.autoSize = TextFieldAutoSize.CENTER;
            t.text = text;
            
            s.addChild(t);
            
            return s;
        }
        
        private function log(msg:String):void {
            logField.text = msg + "\n" + logField.text;
        }
        
    }

}