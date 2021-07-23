import { LightningElement, api, track, wire } from 'lwc';

export default class HdtGenericTable extends LightningElement {

    //inputs 
    @api columns;
    @api rowsData;
    @api tableName;

    //utilities
    @track altMessage;

    //data are retrieved on the callback, on error alternate will be shown
    connectedCallback(){

    }


}