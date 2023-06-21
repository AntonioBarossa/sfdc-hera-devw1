import { LightningElement, api } from 'lwc';
import HdtLandRegistryEdit from 'c/hdtLandRegistryEdit';

export default class HdtLandRegistryEditButton extends LightningElement {

    @api recordId;
    showDelete=false;
    /*connectedCallback(){
        console.log("connCallback")
        this.showSpinner = true;
        this.call_getCadastralCategories();
        //this.call_getCities();
        this._required = true;
        this._readonly = false;
        this._showEdit = true;
        this._showDelete = false;
        this.showSpinner = false;
    }*/

}