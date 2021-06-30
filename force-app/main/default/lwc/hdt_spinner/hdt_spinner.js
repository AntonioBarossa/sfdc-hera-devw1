import { LightningElement, api, track } from 'lwc';
export default class Hdt_spinner extends LightningElement {
	@api size = 'medium';
	@api variant = 'brand';
	@api disableAssistiveText = false;
	@api startOnInit = false;
	@api isfixed = false;
	@track loading = '';
	@track visible = false;
	cssclass = '';
	_startAnnounced = false;
	_startInvoked = false;
	_connected = false;

	
	connectedCallback() {
		if (this.isfixed) this.cssclass = 'slds-is-fixed';
		if (this.startOnInit) this.start();		
		const evt = new CustomEvent('spinnerconnected', { detail: { connected: true } });
		this.dispatchEvent(evt);
	}

	@api
	start() {
		console.log(this);
		this.visible = true;
		this._startInvoked = true;
		if (!this.disableAssistiveText) {
			this._startAnnounced = true;
			if (this.template.querySelector("[data-id='start']")) {
				this.template.querySelector("[data-id='start']").classList.remove('slds-hide');
				this._connected = true;
			}
		}
		else this._startAnnounced = false;
		console.log("Start spinner with _startInvoked:" + this._startInvoked + "_startAnnounced:" + this._startAnnounced + "disableAssistiveText:" + this.disableAssistiveText);
	}

	@api
	stop() {
		console.log("STOPPING SPINNER WITH:" + this.disableAssistiveText);
		console.log(this);		
		if (!this.disableAssistiveText && this._startInvoked && this._startAnnounced) {
			if (this.template.querySelector("[data-id='start']")) this.template.querySelector("[data-id='start']").classList.add('slds-hide');
			if (this.template.querySelector("[data-id='end']")) this.template.querySelector("[data-id='end']").classList.remove('slds-hide');
			setTimeout(() => { if (this.template.querySelector("[data-id='end']")) this.template.querySelector("[data-id='end']").classList.add('slds-hide'); }, 2000);
		}
		this.visible = false;
		console.log("Stop spinner with _startInvoked:" + this._startInvoked + "_startAnnounced:" + this._startAnnounced + "disableAssistiveText:" + this.disableAssistiveText);
	}
	@api get isVisible() { return this.visible; }
}