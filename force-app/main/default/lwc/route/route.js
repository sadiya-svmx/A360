import { LightningElement, api } from 'lwc';

export default class Route extends LightningElement {
    @api route;
    @api currentRoute;

    get isActiveRoute () {
        return this.route === this.currentRoute;
    }
}