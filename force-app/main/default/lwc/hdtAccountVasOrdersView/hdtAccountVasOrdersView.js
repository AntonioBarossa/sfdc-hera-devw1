import { LightningElement, api, wire } from 'lwc';
import getOrders from '@salesforce/apex/HDT_LC_AccountVasOrdersView.getOrders';

const columns = [
    {label: 'Numero ordine', fieldName: 'RecordUrl', type: 'url', typeAttributes: {label: { fieldName: 'OrderNumber' }}},
    {label: 'Stato', fieldName: 'Status', type: 'text'},
    {label: 'Data iniziale ordine', fieldName: 'EffectiveDate', type: 'date', typeAttributes: { year: "numeric", month: "2-digit", day: "2-digit" }},
    {label: 'Numero contratto', fieldName: 'Contract_ContractNumber', type: 'text'},
    {label: 'Ammontare ordine', fieldName: 'TotalAmount', type: 'currency', typeAttributes: { currencyCode: 'EUR', step: '0.01'}},
    {label: 'POD/PdR', fieldName: 'ServicePointCodeFormula__c', type: 'text'}
];

export default class HdtAccountVasOrdersView extends LightningElement {
    columns = columns;

    @api accountId;
    orders;
    error;

    @wire(getOrders, { accountId: '$accountId' })
    wiredContacts({ error, data }) {
        if (data) {
            if (data.length>0) {
                this.orders = this._processOrders(data);
                this.error = undefined;
            }
            else {
                this.error = 'Nessun ordine trovato';
                this.orders = undefined;
            }
        } else if (error) {
            this.error = error.body.message;
            this.orders = undefined;
        }
    }

    _processOrders(orders) {
        var clonedOrders = JSON.parse(JSON.stringify(orders));

        clonedOrders.forEach(order => {
            order["RecordUrl"] = '/'+order.Id;
            if (order.Contract) order["Contract_ContractNumber"] = order.Contract.ContractNumber;
        });

        return clonedOrders;
    }
}