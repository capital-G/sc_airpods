#pragma once
#include <SC_PlugIn.hpp>

static InterfaceTable* ft;

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    double x;
    double y;
    double z;
    double w;
} Quaternion;

typedef struct {
    double x;
    double y;
    double z;
} UserAcceleration;

Quaternion getAirPodsQuaternion();
UserAcceleration getAirPodsUserAcceleration();
bool getAirPodsStatus();

void startAirPodsThread();
void stopAirPodsThread();
#ifdef __cplusplus
}
#endif


class AirPodsQuat : public SCUnit {
public:
    AirPodsQuat() {
        mCalcFunc = make_calc_function<AirPodsQuat, &AirPodsQuat::next_k>();
        startAirPodsThread();
        next_k(1);
    }

    void next_k(int numSamples)
    {
        auto quaternion = getAirPodsQuaternion();
        out0(0) = quaternion.x;
        out0(1) = quaternion.y;
        out0(2) = quaternion.z;
        out0(3) = quaternion.w;
    }
};

class AirPodsAcc : public SCUnit {
public:
    AirPodsAcc() {
        mCalcFunc = make_calc_function<AirPodsAcc, &AirPodsAcc::next_k>();
        startAirPodsThread();
        next_k(1);
    }

    void next_k(int numSamples)
    {
        auto acc = getAirPodsUserAcceleration();
        out0(0) = acc.x;
        out0(1) = acc.y;
        out0(2) = acc.z;
    }
};

class AirPodsStatus : public SCUnit {
public:
    AirPodsStatus() {
        mCalcFunc = make_calc_function<AirPodsStatus, &AirPodsStatus::next_k>();
        startAirPodsThread();
        next_k(1);
    }

    void next_k(int numSamples)
    {
        out0(0) = getAirPodsStatus();
    }
};



PluginLoad("AirPods") {
    registerUnit<AirPodsQuat>(inTable, "AirPodsQuat", false);
    registerUnit<AirPodsAcc>(inTable, "AirPodsAcc", false);
    registerUnit<AirPodsStatus>(inTable, "AirPodsStatus", false);
}

PluginUnload("AirPods") {
    stopAirPodsThread();
}
