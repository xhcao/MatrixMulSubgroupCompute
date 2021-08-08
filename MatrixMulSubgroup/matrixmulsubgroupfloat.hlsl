static const uint3 gl_WorkGroupSize = uint3(16u, 1u, 1u);

ByteAddressBuffer _24 : register(t1);
ByteAddressBuffer _27 : register(t0);
RWByteAddressBuffer _34 : register(u0);

static uint3 gl_WorkGroupID;
static uint3 gl_LocalInvocationID;
static uint3 gl_GlobalInvocationID;
struct SPIRV_Cross_Input
{
    uint3 gl_WorkGroupID : SV_GroupID;
    uint3 gl_LocalInvocationID : SV_GroupThreadID;
    uint3 gl_GlobalInvocationID : SV_DispatchThreadID;
};

static int batch = 0;

void mm_matMul()
{
    int global_x = int(gl_WorkGroupID.x);
    int global_y = int(gl_WorkGroupID.y);
    int local_x = int(gl_LocalInvocationID.x);
    int local_y = int(gl_LocalInvocationID.y);
    float dot00 = 0.0f;
    uint indexRowA = uint(local_x)+((uint(global_y) * 1u) * 384u);
    uint indexColB = uint(local_x)+(uint(global_x) * 16u);
    uint indexRes = (uint(local_x)+(uint(global_x) * 16u)) + ((uint(global_y) * 1u) * 64u);
    uint indexB = indexColB;
    uint indexA = indexRowA;
    float m_B[16] = { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
    float arow = 0.0f;
    uint w = 0u;
    do
    {
        bool inRange = (w + WaveGetLaneIndex()) < 384u;
        if (WaveActiveAllTrue(inRange))
        {
            for (uint i = 0u; i < WaveGetLaneCount(); i++)
            {
                uint _245 = 0u;
                _24.GetDimensions(_245);
                _245 = (_245 - 0) / 4;
                m_B[uint(clamp(int(i), 0, 15))] = asfloat(_24.Load(uint(clamp(int(indexB), int(0u), int(min((_245 - 1u), 2147483647u)))) * 4 + 0));
                indexB += 64u;
            }
            uint _252 = 0u;
            _27.GetDimensions(_252);
            _252 = (_252 - 0) / 4;
            arow = asfloat(_27.Load(uint(clamp(int(indexA), int(0u), int(min((_252 - 1u), 2147483647u)))) * 4 + 0));
            for (uint i_1 = 0u; i_1 < WaveGetLaneCount(); i_1++)
            {
                dot00 += (WaveReadLaneAt(arow, i_1) * m_B[uint(clamp(int(i_1), 0, 15))]);
            }
        }
        else
        {
            uint4 ballotValue = WaveActiveBallot(inRange);
            uint bollotCount = countbits(ballotValue.x) + countbits(ballotValue.y) + countbits(ballotValue.z) + countbits(ballotValue.w);
            for (uint i_2 = 0u; i_2 < bollotCount; i_2++)
            {
                uint _257 = 0u;
                _24.GetDimensions(_257);
                _257 = (_257 - 0) / 4;
                m_B[uint(clamp(int(i_2), 0, 15))] = asfloat(_24.Load(uint(clamp(int(indexB), int(0u), int(min((_257 - 1u), 2147483647u)))) * 4 + 0));
                indexB += 64u;
            }
            uint _262 = 0u;
            _27.GetDimensions(_262);
            _262 = (_262 - 0) / 4;
            arow = asfloat(_27.Load(uint(clamp(int(indexA), int(0u), int(min((_262 - 1u), 2147483647u)))) * 4 + 0));
            for (uint i_3 = 0u; i_3 < bollotCount; i_3++)
            {
                dot00 += (WaveReadLaneAt(arow, i_3) * m_B[uint(clamp(int(i_3), 0, 15))]);
            }
        }
        indexA += WaveGetLaneCount();
        w += WaveGetLaneCount();
    } while (w < 384u);
    bool _229 = (uint(local_x)+(uint(global_x) * 16u)) < 64u;
    bool _239 = false;
    if (_229)
    {
        _239 = (uint(local_y)+(uint(global_y) * 1u)) < 196u;
    }
    else
    {
        _239 = _229;
    }
    if (_239)
    {
        uint _267 = 0u;
        _34.GetDimensions(_267);
        _267 = (_267 - 0) / 4;
        _34.Store(uint(clamp(int(indexRes), int(0u), int(min((_267 - 1u), 2147483647u)))) * 4 + 0, asuint(dot00));
    }
}

void comp_main()
{
    batch = int(gl_GlobalInvocationID.z);
    mm_matMul();
}

[numthreads(16, 1, 1)]
void main(SPIRV_Cross_Input stage_input)
{
    gl_WorkGroupID = stage_input.gl_WorkGroupID;
    gl_LocalInvocationID = stage_input.gl_LocalInvocationID;
    gl_GlobalInvocationID = stage_input.gl_GlobalInvocationID;
    comp_main();
}