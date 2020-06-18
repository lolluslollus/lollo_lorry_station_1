local BuildProposal = 
{
  proposal = {
    proposal = {
      addedNodes = {  },
      addedSegments = {  },
      removedNodes = {  },
      removedSegments = {  },
      edgeObjectsToRemove = {  },
      edgeObjectsToAdd = {  },
      new2oldNodes = {  },
      old2newNodes = {  },
      new2oldSegments = {  },
      old2newSegments = {  },
      new2oldEdgeObjects = {  },
      old2newEdgeObjects = {  },
      frozenNodes = {  }
    },
    terrainAlignSkipEdges = {  },
    segmentTags = {  },
    toRemove = {  },
    toAdd = {  },
    old2new = {  },
    parcelsToRemove = {  }
  },
  context = {
    checkTerrainAlignment = false,
    cleanupStreetGraph = false,
    gatherBuildings = false,
    gatherFields = true,
    player = -1
  },
  withCostRep = false,
  ignoreErrors = false,
  resultProposalData = {
    collisionInfo = {
      collisionEntities = {  },
      autoRemovalEntity2models = {  },
      fieldEntities = {  },
      buildingEntities = {  }
    },
    entity2tn = {  },
    tpNetLinkProposal = {
      toRemove = {  },
      toAdd = {  }
    },
    costs = 0,
    errorState = {
      critical = false,
      messages = {  },
      warnings = {  }
    }
  },
  resultEntities = {  }
}

local Proposal = 
{
  proposal = {
    addedNodes = {  },
    addedSegments = {  },
    removedNodes = {  },
    removedSegments = {  },
    edgeObjectsToRemove = {  },
    edgeObjectsToAdd = {  },
    new2oldNodes = {  },
    old2newNodes = {  },
    new2oldSegments = {  },
    old2newSegments = {  },
    new2oldEdgeObjects = {  },
    old2newEdgeObjects = {  },
    frozenNodes = {  }
  },
  terrainAlignSkipEdges = {  },
  segmentTags = {  },
  toRemove = {  },
  toAdd = {  },
  old2new = {  },
  parcelsToRemove = {  }
}

local ProposalCreateCallbackResult = 
{   errorMessages = {  } }

local ProposalData = 
{
  collisionInfo = {
    collisionEntities = {  },
    autoRemovalEntity2models = {  },
    fieldEntities = {  },
    buildingEntities = {  }
  },
  entity2tn = {  },
  tpNetLinkProposal = {
    toRemove = {  },
    toAdd = {  }
  },
  costs = 0,
  errorState = {
    critical = false,
    messages = {  },
    warnings = {  }
  }
}

-- simple proposal (the one you can build so far)

local SimpleProposal = 
{
  streetProposal = {
    nodesToAdd = {  },
    edgesToAdd = {  },
    nodesToRemove = {  },
    edgesToRemove = {  },
    edgeObjectsToAdd = {  },
    edgeObjectsToRemove = {  }
  },
  constructionsToAdd = {  },
  constructionsToRemove = {  },
  old2new = {  }
}

local SimpleStreetProposal = 
{
  nodesToAdd = {  },
  edgesToAdd = {  },
  nodesToRemove = {  },
  edgesToRemove = {  },
  edgeObjectsToAdd = {  },
  edgeObjectsToRemove = {  }
}

local StreetProposal = 
{
  addedNodes = {  },
  addedSegments = {  },
  removedNodes = {  },
  removedSegments = {  },
  edgeObjectsToRemove = {  },
  edgeObjectsToAdd = {  },
  new2oldNodes = {  },
  old2newNodes = {  },
  new2oldSegments = {  },
  old2newSegments = {  },
  new2oldEdgeObjects = {  },
  old2newEdgeObjects = {  },
  frozenNodes = {  }
}

local TpNetLinkProposal = 
{
  toRemove = {  },
  toAdd = {  }
}