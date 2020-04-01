// Adapt feature and group objects to objects compatible with 
// the optimizer.
#pragma once
#include "optimizer_types.h"
#include "feature.h"
#include "group.h"

namespace xivo {

namespace adapter {

void AddFeature(const FeaturePtr f);
void AddGroup(const GroupPtr g);

} // namespace adapter

} // namespace xivo


