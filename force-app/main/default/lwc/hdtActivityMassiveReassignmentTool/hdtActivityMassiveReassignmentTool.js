import { LightningElement } from 'lwc';
import getData from '@salesforce/apex/HDT_LC_ActivtyMassiveReassignmentTool.getData';

export default class HdtActivityMassiveReassignmentTool extends LightningElement {
    data;
    columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    selectedRows;

    async connectedCallback() {
        try {
            const result = await getData();
            this.data = result.rows;
            this.columns = result.columns;
        } catch (error) {
            console.error(error);
        }
    }

    selectRows(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    // Used to sort the 'Age' column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}