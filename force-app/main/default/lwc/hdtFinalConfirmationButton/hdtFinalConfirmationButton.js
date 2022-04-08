import { LightningElement, api } from 'lwc';
import cttoolbar from '@salesforce/resourceUrl/toolbar_sdk';
import { loadScript } from 'lightning/platformResourceLoader';
import getCachedUuid from '@salesforce/apex/HDT_LC_CtToolbar.getCachedUuid';    // params: n/a
import { CloseActionScreenEvent } from 'lightning/actions';

export default class HdtFinalConfirmationButton extends LightningElement {

    connectedCallback() {
        Promise.all([
            loadScript(this, cttoolbar)
        ]).then(() => {
            console.log('# javascript Loaded #');
            this.saveScript('Conferma IVR', true);
        })
        .catch(error => console.log('promise error: ' + error));
    }

    @api saveScript(esito, isResponsed) {
        console.log('INSIDE SAVESCRIPT');
        getCachedUuid().then(cachedUuid => {
            console.log('getCachedUuid().then' + cachedUuid);
            if(cachedUuid==null){
                console.log('dentro null ');
                this.dispatchEvent(new CustomEvent('close'));
            }
            window.TOOLBAR.EASYCIM.saveScript(cachedUuid, esito, isResponsed)
            .then(() => {
                console.log('getCachedUuid().then savescript.then()' + cachedUuid);
                //this.saveScriptDone = true;
                this.dispatchEvent(new CustomEvent('close'));
            });
        });
    }
}