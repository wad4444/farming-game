local RunService = game:GetService("RunService")
local ReplicaService = require(script.ReplicaService)
local ReplicaController = require(script.ReplicaController)

type Replica = {
	Data: {[any]: any},
	Id: number,
	Class: string,
	Tags: {[any]: any},
	Parent: Replica | nil,
	Children: {[any]: any},
}

export type ClientReplica = Replica & ReplicaController.Replica
export type ServerReplica = Replica & ReplicaService.Replica

if (RunService:IsServer()) then
    return ReplicaService
elseif (RunService:IsClient()) then
    return ReplicaController
end