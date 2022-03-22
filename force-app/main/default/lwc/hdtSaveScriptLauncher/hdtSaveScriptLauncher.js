import { LightningElement,api } from 'lwc';
import getCachedUuid from '@salesforce/apex/HDT_LC_CtToolbar.getCachedUuid';    // params: n/a

export default class HdtSaveScriptLauncher extends LightningElement {

    @api async saveScript(esito, isResponsed) {
        window.TOOLBAR.EASYCIM.saveScript(await getCachedUuid(), esito, isResponsed);
    }
}