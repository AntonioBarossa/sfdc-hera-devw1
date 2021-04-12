import { LightningElement } from 'lwc';

const columns = [
    { label: 'Numero bolletta', fieldName: 'billNumber' },
    { label: 'Data registrazione', fieldName: 'billDate'}
];

export default class HdtBillList extends LightningElement {

    data = [];
    columns = columns;

    connectedCallback(){
        const data = [
            {id: '1', billNumber: '001', billDate: '21/02/2020'},
            {id: '2', billNumber: '002', billDate: '13/06/2020'},
            {id: '3', billNumber: '003', billDate: '29/08/2020'}
        ];

        this.data = data;
    }

    /*clickOperation(event){
        var dataSet = event.currentTarget.dataset;
        this.stmtName = dataSet.id;

        const closeEvent = new CustomEvent("choisestmt", {
            detail:  {
                stmtName: this.stmtName, stmtLabel: dataSet.label
            }
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
        this.stmtName = '';
    }*/

    closeModal(event){
        console.log('# closeModal #');
        const closeEvent = new CustomEvent("closemodal", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }
}