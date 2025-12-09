import { ModifyCustomEntityCommand } from "@workadventure/map-editor";
import { ModifyCustomEntityMessage } from "@workadventure/messages";
import { RoomConnection } from "../../../../../Connection/RoomConnection";
import { FrontCommand } from "../FrontCommand";
import { EntitiesCollectionsManager } from "../../EntitiesCollectionsManager";
import { GameMapFrontWrapper } from "../../../GameMap/GameMapFrontWrapper";
import { EntitiesManager } from "../../../GameMap/EntitiesManager";

export class ModifyCustomEntityFrontCommand extends ModifyCustomEntityCommand implements FrontCommand {
    constructor(
        modifyCustomEntityMessage: ModifyCustomEntityMessage,
        private entitiesCollectionManager: EntitiesCollectionsManager,
        private gameFrontWrapper: GameMapFrontWrapper,
        private entitiesManager: EntitiesManager
    ) {
        super(modifyCustomEntityMessage);
    }

    emitEvent(roomConnection: RoomConnection): void {
        console.log("ModifyCustomEntityFrontCommand: emitEvent", this.modifyCustomEntityMessage);
        roomConnection.emitMapEditorModifyCustomEntity(this.commandId, this.modifyCustomEntityMessage);
    }

    async execute(): Promise<void> {
        console.log("ModifyCustomEntityFrontCommand: execute", this.modifyCustomEntityMessage);
        const { id, name, tags, depthOffset, collisionGrid } = this.modifyCustomEntityMessage;
        this.entitiesCollectionManager.modifyCustomEntity(id, name, tags, depthOffset, collisionGrid);

        // Fetch the updated prefab to ensure we have the latest data
        const prefab = await this.entitiesCollectionManager.getEntityPrefab("custom entities", id);
        if (prefab) {
            const entities = this.entitiesManager.getEntities();
            for (const entity of entities.values()) {
                if (entity.getPrefab().id === id) {
                    entity.updatePrefab(prefab);
                }
            }
        }

        if (depthOffset !== undefined) {
            this.entitiesManager.updateEntitiesDepth(id, depthOffset);
        }
        this.gameFrontWrapper.recomputeEntitiesCollisionGrid();
        return super.execute();
    }

    getUndoCommand(): ModifyCustomEntityFrontCommand {
        throw new Error("Not supported.");
    }
}
