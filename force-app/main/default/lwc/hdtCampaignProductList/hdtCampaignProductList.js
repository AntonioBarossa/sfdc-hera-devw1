import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllProducts from '@salesforce/apex/HDT_LC_CampaignsController.getAllProducts';
import assignSelectedProducts from '@salesforce/apex/HDT_LC_CampaignsController.assignSelectedProducts';

export default class HdtCampaignProductList extends LightningElement {
    columnsList = [
        { label: 'Product Name', fieldName: 'name' },
    ];
    @api recordId;
    @track dataList = [];
    @track preSelectedRows = [];
    @track showTable = false;
    @track refreshData = [];

    @wire(getAllProducts, { IdGruppoEleggibilitCampagne: '$recordId' })
    wiredData(result) {
        this.refreshData = result;
        let { data, error } = result;
         console.log('fuori if');
        if (data) {
            console.log('dentro if');
            console.log(JSON.stringify(data));
            this.preSelectedRows = [];
            data.forEach(prod => {
                let row = {
                    "id": prod.Id,
                    "name": prod.Name,
                };
                this.dataList.push(row);
                if (prod.CampaignEleggibilityGroup__c != null) {
                    this.preSelectedRows.push(prod.Id);
                }
            });

            this.showTable = true;
            console.log(JSON.stringify(this.preSelectedRows));
        } else if (error) {
            console.error('Error:', error);
        }
    }

    assignSelectedProductsHandler() {
        let rowsToUpdate = this.template.querySelector('lightning-datatable.productDt').getSelectedRows();
        let selectedIds = [];
        let unselectedIds = [];
        rowsToUpdate.forEach(row => {
            selectedIds.push(row.id);
        });
        this.preSelectedRows.forEach(row => {
            if (selectedIds.indexOf(row) == -1) {
                unselectedIds.push(row);
            }
        });
        if (selectedIds.length == 0 && unselectedIds.length == 0) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Nessun prodotto selezionato!',
                variant: 'error'
            }));
        } else {
            //assign selected products
            assignSelectedProducts({
                IdGruppoEleggibilitCampagne: this.recordId,
                productIds: selectedIds,
                deselectProductIds: unselectedIds
            }).then(data => {
                refreshApex(this.refreshData);
                console.log(JSON.stringify(data));
                if (data == 'success') {
                    this.dispatchEvent(new ShowToastEvent({
                        title: '',
                        message: 'Prodotti aggiornati con successo!',
                        variant: 'success'
                    }));
                } else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: data,
                        variant: 'error'
                    }));
                }
            }).catch(err => {
                console.log('error: ' + JSON.stringify(err));
            });
        }
    }

}