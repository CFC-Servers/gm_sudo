local a = false
local unpack, b, c, d, e, f, g, h, i, j, k, l, m, tonumber, type = table.unpack or unpack, table.concat, string.byte, string.char, string.rep, string.sub, string.gsub, string.gmatch, string.format, math.floor, math.ceil, math.min, math.max, tonumber, type

local function n(o)
	local p, q, r, s = 0, o, o

	while true do
		p, s, q, r = p + 1, q, q + q + 1, r + r + p % 2

		if p > 256 or q - (q - 1) ~= 1 or r - (r - 1) ~= 1 or q == r then
			return p, false
		elseif q == s then
			return p, true
		end
	end
end

local t = 2 / 3
local u = t * 5 > 3 and t * 4 < 3 and n(1.0) >= 53
assert(u, "at least 53-bit floating point numbers are required")
local v, w = n(1)
local x = w and v == 64
local y = w and v == 32
assert(x or y or not w, "Lua integers must be either 32-bit or 64-bit")

local z = ({
	false, [1] = true
})[1] and (type(jit) ~= "table" or jit.version_num >= 20000)

local A
local B
local C
local D
local E

if z then
	D = bit
	E = "bit"
	A = not RunString("b=0b0", "is_LuaJIT_21")
	B = type(jit) == "table" and jit.arch or C and C.arch or nil
else
	for H, I in ipairs(_VERSION == "Lua 5.2" and {"bit32", "bit"} or {"bit", "bit32"}) do
		if type(_G[I]) == "table" and _G[I].bxor then
			D = _G[I]
			E = I
			break
		end
	end
end

if a then
	print("Abilities:")
	print("   Lua version:               " .. (z and "LuaJIT " .. (A and "2.1 " or "2.0 ") .. (B or "") .. (C and " with FFI" or " without FFI") or _VERSION))
	print("   Integer bitwise operators: " .. (x and "int64" or y and "int32" or "no"))
	print("   32-bit bitwise library:    " .. (E or "not found"))
end

local J, K

if z and C then
	J = "Using 'ffi' library of LuaJIT"
	K = "FFI"
elseif z then
	J = "Using special code for FFI-less LuaJIT"
	K = "LJ"
elseif x then
	J = "Using native int64 bitwise operators"
	K = "INT64"
elseif y then
	J = "Using native int32 bitwise operators"
	K = "INT32"
elseif E then
	J = "Using '" .. E .. "' library"
	K = "LIB32"
else
	J = "Emulating bitwise operators using look-up table"
	K = "EMUL"
end

if a then
	print("Implementation selected:")
	print("   " .. J)
end

local L, M, N, O, P, Q, R, S, T, U, V

if K == "FFI" or K == "LJ" or K == "LIB32" then
	L = D.band
	M = D.bor
	N = D.bxor
	O = D.lshift
	P = D.rshift
	Q = D.rol or D.lrotate
	R = D.ror or D.rrotate
	S = D.bnot
	T = D.tobit
	U = D.tohex
	assert(L and M and N and O and P and Q and R and S, "Library '" .. E .. "' is incomplete")
	V = N
elseif K == "EMUL" then
	function O(t, q)
		return t * 2 ^ q % 2 ^ 32
	end

	function P(t, q)
		t = t % 2 ^ 32 / 2 ^ q

		return t - t % 1
	end

	function Q(t, q)
		t = t % 2 ^ 32 * 2 ^ q
		local W = t % 2 ^ 32

		return W + (t - W) / 2 ^ 32
	end

	function R(t, q)
		t = t % 2 ^ 32 / 2 ^ q
		local W = t % 1

		return W * 2 ^ 32 + t - W
	end

	local X = {
		[0] = 0
	}

	local Y = 0

	for Z = 0, 127 * 256, 256 do
		for t = Z, Z + 127 do
			t = X[t] * 2
			X[Y] = t
			X[Y + 1] = t
			X[Y + 256] = t
			X[Y + 257] = t + 1
			Y = Y + 2
		end

		Y = Y + 256
	end

	local function _(t, Z, a0)
		local a1 = t % 2 ^ 32
		local a2 = Z % 2 ^ 32
		local a3 = a1 % 256
		local a4 = a2 % 256
		local a5 = X[a3 + a4 * 256]
		t = a1 - a3
		Z = (a2 - a4) / 256
		a3 = t % 65536
		a4 = Z % 256
		a5 = a5 + X[a3 + a4] * 256
		t = (t - a3) / 256
		Z = (Z - a4) / 256
		a3 = t % 65536 + Z % 256
		a5 = a5 + X[a3] * 65536
		a5 = a5 + X[(t + Z - a3) / 256] * 16777216

		if a0 then
			a5 = a1 + a2 - a0 * a5
		end

		return a5
	end

	function L(t, Z)
		return _(t, Z)
	end

	function M(t, Z)
		return _(t, Z, 1)
	end

	function N(t, Z, a6, a7, a8)
		if a6 then
			if a7 then
				if a8 then
					a7 = _(a7, a8, 2)
				end

				a6 = _(a6, a7, 2)
			end

			Z = _(Z, a6, 2)
		end

		return _(t, Z, 2)
	end

	function V(t, Z)
		return t + Z - 2 * X[t + Z * 256]
	end
end

U = U or pcall(i, "%x", 2 ^ 31) and function(t) return i("%08x", t % 4294967296) end or function(t) return i("%08x", (t + 2 ^ 31) % 2 ^ 32 - 2 ^ 31) end

local function a9(t)
	return N(t, 0xA5A5A5A5) % 4294967296
end

local function aa()
	return {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
end

local ab, ac, ad, ae, af
local ag, ah, ai, aj, ak, al = {}, {}, {}, {}, {}, {}

local am = {
	[224] = {},
	[256] = aj
}

local an, ao = {
	[384] = {},
	[512] = ai
}, {
	[384] = {},
	[512] = aj
}

local ap, aq = {}, {0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0}

local ar = {0, 0, 0, 0, 0, 0, 0, 0, 28, 25, 26, 27, 0, 0, 10, 9, 11, 12, 0, 15, 16, 17, 18, 0, 20, 22, 23, 21}

local as, at, au
local av = {}
local aw, ax, ay = 4294967296, 0, 0

local function az(aA)
	local aB = {}

	for H, aC in ipairs{1, 9, 13, 17, 18, 21} do
		aB[aC] = "<" .. e(aA, aC)
	end

	return aB
end

if K == "FFI" then
	local aD = C.new"int32_t[80]"

	function ab(aE, aF, aG, aC)
		local aH, aI = aD, ah

		for aJ = aG, aG + aC - 1, 64 do
			for aK = 0, 15 do
				aJ = aJ + 4
				local aL, D, aM, aN = c(aF, aJ - 3, aJ)
				aH[aK] = M(O(aL, 24), O(D, 16), O(aM, 8), aN)
			end

			for aK = 16, 63 do
				local aL, D = aH[aK - 15], aH[aK - 2]
				aH[aK] = T(N(R(aL, 7), Q(aL, 14), P(aL, 3)) + N(Q(D, 15), Q(D, 13), P(D, 10)) + aH[aK - 7] + aH[aK - 16])
			end

			local aL, D, aM, aN, aO, aP, aQ, aR = aE[1], aE[2], aE[3], aE[4], aE[5], aE[6], aE[7], aE[8]

			for aK = 0, 63, 8 do
				local a6 = T(N(aQ, L(aO, N(aP, aQ))) + N(R(aO, 6), R(aO, 11), Q(aO, 7)) + aH[aK] + aI[aK + 1] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(aQ, L(aO, N(aP, aQ))) + N(R(aO, 6), R(aO, 11), Q(aO, 7)) + aH[aK + 1] + aI[aK + 2] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(aQ, L(aO, N(aP, aQ))) + N(R(aO, 6), R(aO, 11), Q(aO, 7)) + aH[aK + 2] + aI[aK + 3] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(aQ, L(aO, N(aP, aQ))) + N(R(aO, 6), R(aO, 11), Q(aO, 7)) + aH[aK + 3] + aI[aK + 4] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(aQ, L(aO, N(aP, aQ))) + N(R(aO, 6), R(aO, 11), Q(aO, 7)) + aH[aK + 4] + aI[aK + 5] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(aQ, L(aO, N(aP, aQ))) + N(R(aO, 6), R(aO, 11), Q(aO, 7)) + aH[aK + 5] + aI[aK + 6] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(aQ, L(aO, N(aP, aQ))) + N(R(aO, 6), R(aO, 11), Q(aO, 7)) + aH[aK + 6] + aI[aK + 7] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(aQ, L(aO, N(aP, aQ))) + N(R(aO, 6), R(aO, 11), Q(aO, 7)) + aH[aK + 7] + aI[aK + 8] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
			end

			aE[1], aE[2], aE[3], aE[4] = T(aL + aE[1]), T(D + aE[2]), T(aM + aE[3]), T(aN + aE[4])
			aE[5], aE[6], aE[7], aE[8] = T(aO + aE[5]), T(aP + aE[6]), T(aQ + aE[7]), T(aR + aE[8])
		end
	end

	local aS = C.new"int64_t[80]"
	local aT = C.typeof"int64_t"
	local aU = C.typeof"int32_t"
	local aV = C.typeof"uint32_t"
	ax = aT(2 ^ 32)

	if A then
		local aW, aX, aY, aZ, a_, b0, b1, b2 = L, M, N, S, O, P, Q, R
		as = U
		local b3 = C.typeof"int64_t[30]"
		au = 0
		ay = aT(2 ^ 32)

		function aa()
			return b3()
		end

		function af(b4, H, aF, aG, aC, b5)
			local b6 = ak
			local b7 = P(b5, 3)

			for aJ = aG, aG + aC - 1, b5 do
				for aK = 0, b7 - 1 do
					aJ = aJ + 8
					local aR, aQ, aP, aO, aN, aM, D, aL = c(aF, aJ - 7, aJ)
					b4[aK] = aY(b4[aK], aX(M(O(aL, 24), O(D, 16), O(aM, 8), aN) * aT(2 ^ 32), aV(aU(M(O(aO, 24), O(aP, 16), O(aQ, 8), aR)))))
				end

				for b8 = 1, 24 do
					for aK = 0, 4 do
						b4[25 + aK] = aY(b4[aK], b4[aK + 5], b4[aK + 10], b4[aK + 15], b4[aK + 20])
					end

					local b9 = aY(b4[25], b1(b4[27], 1))
					b4[1], b4[6], b4[11], b4[16] = b1(aY(b9, b4[6]), 44), b1(aY(b9, b4[16]), 45), b1(aY(b9, b4[1]), 1), b1(aY(b9, b4[11]), 10)
					b4[21] = b1(aY(b9, b4[21]), 2)
					b9 = aY(b4[26], b1(b4[28], 1))
					b4[2], b4[7], b4[12], b4[22] = b1(aY(b9, b4[12]), 43), b1(aY(b9, b4[22]), 61), b1(aY(b9, b4[7]), 6), b1(aY(b9, b4[2]), 62)
					b4[17] = b1(aY(b9, b4[17]), 15)
					b9 = aY(b4[27], b1(b4[29], 1))
					b4[3], b4[8], b4[18], b4[23] = b1(aY(b9, b4[18]), 21), b1(aY(b9, b4[3]), 28), b1(aY(b9, b4[23]), 56), b1(aY(b9, b4[8]), 55)
					b4[13] = b1(aY(b9, b4[13]), 25)
					b9 = aY(b4[28], b1(b4[25], 1))
					b4[4], b4[14], b4[19], b4[24] = b1(aY(b9, b4[24]), 14), b1(aY(b9, b4[19]), 8), b1(aY(b9, b4[4]), 27), b1(aY(b9, b4[14]), 39)
					b4[9] = b1(aY(b9, b4[9]), 20)
					b9 = aY(b4[29], b1(b4[26], 1))
					b4[5], b4[10], b4[15], b4[20] = b1(aY(b9, b4[10]), 3), b1(aY(b9, b4[20]), 18), b1(aY(b9, b4[5]), 36), b1(aY(b9, b4[15]), 41)
					b4[0] = aY(b9, b4[0])
					b4[0], b4[1], b4[2], b4[3], b4[4] = aY(b4[0], aW(aZ(b4[1]), b4[2]), b6[b8]), aY(b4[1], aW(aZ(b4[2]), b4[3])), aY(b4[2], aW(aZ(b4[3]), b4[4])), aY(b4[3], aW(aZ(b4[4]), b4[0])), aY(b4[4], aW(aZ(b4[0]), b4[1]))
					b4[5], b4[6], b4[7], b4[8], b4[9] = aY(b4[8], aW(aZ(b4[9]), b4[5])), aY(b4[9], aW(aZ(b4[5]), b4[6])), aY(b4[5], aW(aZ(b4[6]), b4[7])), aY(b4[6], aW(aZ(b4[7]), b4[8])), aY(b4[7], aW(aZ(b4[8]), b4[9]))
					b4[10], b4[11], b4[12], b4[13], b4[14] = aY(b4[11], aW(aZ(b4[12]), b4[13])), aY(b4[12], aW(aZ(b4[13]), b4[14])), aY(b4[13], aW(aZ(b4[14]), b4[10])), aY(b4[14], aW(aZ(b4[10]), b4[11])), aY(b4[10], aW(aZ(b4[11]), b4[12]))
					b4[15], b4[16], b4[17], b4[18], b4[19] = aY(b4[19], aW(aZ(b4[15]), b4[16])), aY(b4[15], aW(aZ(b4[16]), b4[17])), aY(b4[16], aW(aZ(b4[17]), b4[18])), aY(b4[17], aW(aZ(b4[18]), b4[19])), aY(b4[18], aW(aZ(b4[19]), b4[15]))
					b4[20], b4[21], b4[22], b4[23], b4[24] = aY(b4[22], aW(aZ(b4[23]), b4[24])), aY(b4[23], aW(aZ(b4[24]), b4[20])), aY(b4[24], aW(aZ(b4[20]), b4[21])), aY(b4[20], aW(aZ(b4[21]), b4[22])), aY(b4[21], aW(aZ(b4[22]), b4[23]))
				end
			end
		end

		local ba = 0xA5A5A5A5 * aT(2 ^ 32 + 1)

		function at(bb)
			return aY(bb, ba)
		end

		function ac(aE, H, aF, aG, aC)
			local aH, aI = aS, ag

			for aJ = aG, aG + aC - 1, 128 do
				for aK = 0, 15 do
					aJ = aJ + 8
					local aL, D, aM, aN, aO, aP, aQ, aR = c(aF, aJ - 7, aJ)
					aH[aK] = aX(M(O(aL, 24), O(D, 16), O(aM, 8), aN) * aT(2 ^ 32), aV(aU(M(O(aO, 24), O(aP, 16), O(aQ, 8), aR))))
				end

				for aK = 16, 79 do
					local aL, D = aH[aK - 15], aH[aK - 2]
					aH[aK] = aY(b2(aL, 1), b2(aL, 8), b0(aL, 7)) + aY(b2(D, 19), b1(D, 3), b0(D, 6)) + aH[aK - 7] + aH[aK - 16]
				end

				local aL, D, aM, aN, aO, aP, aQ, aR = aE[1], aE[2], aE[3], aE[4], aE[5], aE[6], aE[7], aE[8]

				for aK = 0, 79, 8 do
					local a6 = aY(b2(aO, 14), b2(aO, 18), b1(aO, 23)) + aY(aQ, aW(aO, aY(aP, aQ))) + aR + aI[aK + 1] + aH[aK]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, aY(aW(aY(aL, D), aM), aW(aL, D)) + aY(b2(aL, 28), b1(aL, 25), b1(aL, 30)) + a6
					a6 = aY(b2(aO, 14), b2(aO, 18), b1(aO, 23)) + aY(aQ, aW(aO, aY(aP, aQ))) + aR + aI[aK + 2] + aH[aK + 1]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, aY(aW(aY(aL, D), aM), aW(aL, D)) + aY(b2(aL, 28), b1(aL, 25), b1(aL, 30)) + a6
					a6 = aY(b2(aO, 14), b2(aO, 18), b1(aO, 23)) + aY(aQ, aW(aO, aY(aP, aQ))) + aR + aI[aK + 3] + aH[aK + 2]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, aY(aW(aY(aL, D), aM), aW(aL, D)) + aY(b2(aL, 28), b1(aL, 25), b1(aL, 30)) + a6
					a6 = aY(b2(aO, 14), b2(aO, 18), b1(aO, 23)) + aY(aQ, aW(aO, aY(aP, aQ))) + aR + aI[aK + 4] + aH[aK + 3]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, aY(aW(aY(aL, D), aM), aW(aL, D)) + aY(b2(aL, 28), b1(aL, 25), b1(aL, 30)) + a6
					a6 = aY(b2(aO, 14), b2(aO, 18), b1(aO, 23)) + aY(aQ, aW(aO, aY(aP, aQ))) + aR + aI[aK + 5] + aH[aK + 4]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, aY(aW(aY(aL, D), aM), aW(aL, D)) + aY(b2(aL, 28), b1(aL, 25), b1(aL, 30)) + a6
					a6 = aY(b2(aO, 14), b2(aO, 18), b1(aO, 23)) + aY(aQ, aW(aO, aY(aP, aQ))) + aR + aI[aK + 6] + aH[aK + 5]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, aY(aW(aY(aL, D), aM), aW(aL, D)) + aY(b2(aL, 28), b1(aL, 25), b1(aL, 30)) + a6
					a6 = aY(b2(aO, 14), b2(aO, 18), b1(aO, 23)) + aY(aQ, aW(aO, aY(aP, aQ))) + aR + aI[aK + 7] + aH[aK + 6]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, aY(aW(aY(aL, D), aM), aW(aL, D)) + aY(b2(aL, 28), b1(aL, 25), b1(aL, 30)) + a6
					a6 = aY(b2(aO, 14), b2(aO, 18), b1(aO, 23)) + aY(aQ, aW(aO, aY(aP, aQ))) + aR + aI[aK + 8] + aH[aK + 7]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, aY(aW(aY(aL, D), aM), aW(aL, D)) + aY(b2(aL, 28), b1(aL, 25), b1(aL, 30)) + a6
				end

				aE[1] = aL + aE[1]
				aE[2] = D + aE[2]
				aE[3] = aM + aE[3]
				aE[4] = aN + aE[4]
				aE[5] = aO + aE[5]
				aE[6] = aP + aE[6]
				aE[7] = aQ + aE[7]
				aE[8] = aR + aE[8]
			end
		end
	else
		local bc = C.typeof"union{int64_t i64; struct{int32_t lo, hi;} i32;}"

		do
			local a8 = bc(1)

			if a8.i32.lo < a8.i32.hi then
				bc = C.typeof"union{int64_t i64; struct{int32_t hi, lo;} i32;}"
			end
		end

		local bd = C.typeof("$[?]", bc)
		local be = bd(3)

		local function bf(aL)
			be[0].i64 = aL
			local bg, bh = be[0].i32.lo, be[0].i32.hi
			local bi = N(M(P(bg, 1), O(bh, 31)), M(P(bg, 8), O(bh, 24)), M(P(bg, 7), O(bh, 25)))
			local bj = N(M(P(bh, 1), O(bg, 31)), M(P(bh, 8), O(bg, 24)), P(bh, 7))

			return bj * aT(2 ^ 32) + aV(aU(bi))
		end

		local function bk(D)
			be[0].i64 = D
			local bl, bm = be[0].i32.lo, be[0].i32.hi
			local bn = N(M(P(bl, 19), O(bm, 13)), M(O(bl, 3), P(bm, 29)), M(P(bl, 6), O(bm, 26)))
			local bo = N(M(P(bm, 19), O(bl, 13)), M(O(bm, 3), P(bl, 29)), P(bm, 6))

			return bo * aT(2 ^ 32) + aV(aU(bn))
		end

		local function bp(aO)
			be[0].i64 = aO
			local bq, br = be[0].i32.lo, be[0].i32.hi
			local bn = N(M(P(bq, 14), O(br, 18)), M(P(bq, 18), O(br, 14)), M(O(bq, 23), P(br, 9)))
			local bo = N(M(P(br, 14), O(bq, 18)), M(P(br, 18), O(bq, 14)), M(O(br, 23), P(bq, 9)))

			return bo * aT(2 ^ 32) + aV(aU(bn))
		end

		local function bs(aL)
			be[0].i64 = aL
			local bl, bm = be[0].i32.lo, be[0].i32.hi
			local bn = N(M(P(bl, 28), O(bm, 4)), M(O(bl, 30), P(bm, 2)), M(O(bl, 25), P(bm, 7)))
			local bo = N(M(P(bm, 28), O(bl, 4)), M(O(bm, 30), P(bl, 2)), M(O(bm, 25), P(bl, 7)))

			return bo * aT(2 ^ 32) + aV(aU(bn))
		end

		local function bt(aO, aP, aQ)
			be[0].i64 = aP
			be[1].i64 = aQ
			be[2].i64 = aO
			local bu, bv = be[0].i32.lo, be[0].i32.hi
			local bw, bx = be[1].i32.lo, be[1].i32.hi
			local bq, br = be[2].i32.lo, be[2].i32.hi
			local by = N(bw, L(bq, N(bu, bw)))
			local bz = N(bx, L(br, N(bv, bx)))

			return bz * aT(2 ^ 32) + aV(aU(by))
		end

		local function bA(aL, D, aM)
			be[0].i64 = aL
			be[1].i64 = D
			be[2].i64 = aM
			local bg, bh = be[0].i32.lo, be[0].i32.hi
			local bl, bm = be[1].i32.lo, be[1].i32.hi
			local bB, bC = be[2].i32.lo, be[2].i32.hi
			local by = N(L(N(bg, bl), bB), L(bg, bl))
			local bz = N(L(N(bh, bm), bC), L(bh, bm))

			return bz * aT(2 ^ 32) + aV(aU(by))
		end

		function at(bb)
			be[0].i64 = bb
			local bD, bE = be[0].i32.lo, be[0].i32.hi
			bD = N(bD, 0xA5A5A5A5)
			bE = N(bE, 0xA5A5A5A5)

			return bE * aT(2 ^ 32) + aV(aU(bD))
		end

		function as(bb)
			be[0].i64 = bb

			return U(be[0].i32.hi) .. U(be[0].i32.lo)
		end

		function ac(aE, H, aF, aG, aC)
			local aH, aI = aS, ag

			for aJ = aG, aG + aC - 1, 128 do
				for aK = 0, 15 do
					aJ = aJ + 8
					local aL, D, aM, aN, aO, aP, aQ, aR = c(aF, aJ - 7, aJ)
					aH[aK] = M(O(aL, 24), O(D, 16), O(aM, 8), aN) * aT(2 ^ 32) + aV(aU(M(O(aO, 24), O(aP, 16), O(aQ, 8), aR)))
				end

				for aK = 16, 79 do
					aH[aK] = bf(aH[aK - 15]) + bk(aH[aK - 2]) + aH[aK - 7] + aH[aK - 16]
				end

				local aL, D, aM, aN, aO, aP, aQ, aR = aE[1], aE[2], aE[3], aE[4], aE[5], aE[6], aE[7], aE[8]

				for aK = 0, 79, 8 do
					local a6 = bp(aO) + bt(aO, aP, aQ) + aR + aI[aK + 1] + aH[aK]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, bA(aL, D, aM) + bs(aL) + a6
					a6 = bp(aO) + bt(aO, aP, aQ) + aR + aI[aK + 2] + aH[aK + 1]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, bA(aL, D, aM) + bs(aL) + a6
					a6 = bp(aO) + bt(aO, aP, aQ) + aR + aI[aK + 3] + aH[aK + 2]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, bA(aL, D, aM) + bs(aL) + a6
					a6 = bp(aO) + bt(aO, aP, aQ) + aR + aI[aK + 4] + aH[aK + 3]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, bA(aL, D, aM) + bs(aL) + a6
					a6 = bp(aO) + bt(aO, aP, aQ) + aR + aI[aK + 5] + aH[aK + 4]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, bA(aL, D, aM) + bs(aL) + a6
					a6 = bp(aO) + bt(aO, aP, aQ) + aR + aI[aK + 6] + aH[aK + 5]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, bA(aL, D, aM) + bs(aL) + a6
					a6 = bp(aO) + bt(aO, aP, aQ) + aR + aI[aK + 7] + aH[aK + 6]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, bA(aL, D, aM) + bs(aL) + a6
					a6 = bp(aO) + bt(aO, aP, aQ) + aR + aI[aK + 8] + aH[aK + 7]
					aR, aQ, aP, aO = aQ, aP, aO, a6 + aN
					aN, aM, D, aL = aM, D, aL, bA(aL, D, aM) + bs(aL) + a6
				end

				aE[1] = aL + aE[1]
				aE[2] = D + aE[2]
				aE[3] = aM + aE[3]
				aE[4] = aN + aE[4]
				aE[5] = aO + aE[5]
				aE[6] = aP + aE[6]
				aE[7] = aQ + aE[7]
				aE[8] = aR + aE[8]
			end
		end
	end

	function ad(aE, aF, aG, aC)
		local aH, aI = aD, ap

		for aJ = aG, aG + aC - 1, 64 do
			for aK = 0, 15 do
				aJ = aJ + 4
				local aL, D, aM, aN = c(aF, aJ - 3, aJ)
				aH[aK] = M(O(aN, 24), O(aM, 16), O(D, 8), aL)
			end

			local aL, D, aM, aN = aE[1], aE[2], aE[3], aE[4]

			for aK = 0, 15, 4 do
				aL, aN, aM, D = aN, aM, D, T(Q(N(aN, L(D, N(aM, aN))) + aI[aK + 1] + aH[aK] + aL, 7) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aN, L(D, N(aM, aN))) + aI[aK + 2] + aH[aK + 1] + aL, 12) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aN, L(D, N(aM, aN))) + aI[aK + 3] + aH[aK + 2] + aL, 17) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aN, L(D, N(aM, aN))) + aI[aK + 4] + aH[aK + 3] + aL, 22) + D)
			end

			for aK = 16, 31, 4 do
				local aQ = 5 * aK
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, L(aN, N(D, aM))) + aI[aK + 1] + aH[L(aQ + 1, 15)] + aL, 5) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, L(aN, N(D, aM))) + aI[aK + 2] + aH[L(aQ + 6, 15)] + aL, 9) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, L(aN, N(D, aM))) + aI[aK + 3] + aH[L(aQ - 5, 15)] + aL, 14) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, L(aN, N(D, aM))) + aI[aK + 4] + aH[L(aQ, 15)] + aL, 20) + D)
			end

			for aK = 32, 47, 4 do
				local aQ = 3 * aK
				aL, aN, aM, D = aN, aM, D, T(Q(N(D, aM, aN) + aI[aK + 1] + aH[L(aQ + 5, 15)] + aL, 4) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(D, aM, aN) + aI[aK + 2] + aH[L(aQ + 8, 15)] + aL, 11) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(D, aM, aN) + aI[aK + 3] + aH[L(aQ - 5, 15)] + aL, 16) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(D, aM, aN) + aI[aK + 4] + aH[L(aQ - 2, 15)] + aL, 23) + D)
			end

			for aK = 48, 63, 4 do
				local aQ = 7 * aK
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, M(D, S(aN))) + aI[aK + 1] + aH[L(aQ, 15)] + aL, 6) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, M(D, S(aN))) + aI[aK + 2] + aH[L(aQ + 7, 15)] + aL, 10) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, M(D, S(aN))) + aI[aK + 3] + aH[L(aQ - 2, 15)] + aL, 15) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, M(D, S(aN))) + aI[aK + 4] + aH[L(aQ + 5, 15)] + aL, 21) + D)
			end

			aE[1], aE[2], aE[3], aE[4] = T(aL + aE[1]), T(D + aE[2]), T(aM + aE[3]), T(aN + aE[4])
		end
	end

	function ae(aE, aF, aG, aC)
		local aH = aD

		for aJ = aG, aG + aC - 1, 64 do
			for aK = 0, 15 do
				aJ = aJ + 4
				local aL, D, aM, aN = c(aF, aJ - 3, aJ)
				aH[aK] = M(O(aL, 24), O(D, 16), O(aM, 8), aN)
			end

			for aK = 16, 79 do
				aH[aK] = Q(N(aH[aK - 3], aH[aK - 8], aH[aK - 14], aH[aK - 16]), 1)
			end

			local aL, D, aM, aN, aO = aE[1], aE[2], aE[3], aE[4], aE[5]

			for aK = 0, 19, 5 do
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(aN, L(D, N(aN, aM))) + aH[aK] + 0x5A827999 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(aN, L(D, N(aN, aM))) + aH[aK + 1] + 0x5A827999 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(aN, L(D, N(aN, aM))) + aH[aK + 2] + 0x5A827999 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(aN, L(D, N(aN, aM))) + aH[aK + 3] + 0x5A827999 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(aN, L(D, N(aN, aM))) + aH[aK + 4] + 0x5A827999 + aO)
			end

			for aK = 20, 39, 5 do
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK] + 0x6ED9EBA1 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 1] + 0x6ED9EBA1 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 2] + 0x6ED9EBA1 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 3] + 0x6ED9EBA1 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 4] + 0x6ED9EBA1 + aO)
			end

			for aK = 40, 59, 5 do
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(L(aN, N(D, aM)), L(D, aM)) + aH[aK] + 0x8F1BBCDC + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(L(aN, N(D, aM)), L(D, aM)) + aH[aK + 1] + 0x8F1BBCDC + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(L(aN, N(D, aM)), L(D, aM)) + aH[aK + 2] + 0x8F1BBCDC + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(L(aN, N(D, aM)), L(D, aM)) + aH[aK + 3] + 0x8F1BBCDC + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(L(aN, N(D, aM)), L(D, aM)) + aH[aK + 4] + 0x8F1BBCDC + aO)
			end

			for aK = 60, 79, 5 do
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK] + 0xCA62C1D6 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 1] + 0xCA62C1D6 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 2] + 0xCA62C1D6 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 3] + 0xCA62C1D6 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 4] + 0xCA62C1D6 + aO)
			end

			aE[1], aE[2], aE[3], aE[4], aE[5] = T(aL + aE[1]), T(D + aE[2]), T(aM + aE[3]), T(aN + aE[4]), T(aO + aE[5])
		end
	end
end

if K == "FFI" and not A or K == "LJ" then
	if K == "FFI" then
		local bF = C.typeof"int32_t[31]"

		function aa()
			return bF()
		end
	end

	function af(bG, bH, aF, aG, aC, b5)
		local bI, bJ = ak, al
		local b7 = P(b5, 3)

		for aJ = aG, aG + aC - 1, b5 do
			for aK = 1, b7 do
				local aL, D, aM, aN = c(aF, aJ + 1, aJ + 4)
				bG[aK] = N(bG[aK], M(O(aN, 24), O(aM, 16), O(D, 8), aL))
				aJ = aJ + 8
				aL, D, aM, aN = c(aF, aJ - 3, aJ)
				bH[aK] = N(bH[aK], M(O(aN, 24), O(aM, 16), O(D, 8), aL))
			end

			for b8 = 1, 24 do
				for aK = 1, 5 do
					bG[25 + aK] = N(bG[aK], bG[aK + 5], bG[aK + 10], bG[aK + 15], bG[aK + 20])
				end

				for aK = 1, 5 do
					bH[25 + aK] = N(bH[aK], bH[aK + 5], bH[aK + 10], bH[aK + 15], bH[aK + 20])
				end

				local bK = N(bG[26], O(bG[28], 1), P(bH[28], 31))
				local bL = N(bH[26], O(bH[28], 1), P(bG[28], 31))
				bG[2], bH[2], bG[7], bH[7], bG[12], bH[12], bG[17], bH[17] = N(P(N(bK, bG[7]), 20), O(N(bL, bH[7]), 12)), N(P(N(bL, bH[7]), 20), O(N(bK, bG[7]), 12)), N(P(N(bK, bG[17]), 19), O(N(bL, bH[17]), 13)), N(P(N(bL, bH[17]), 19), O(N(bK, bG[17]), 13)), N(O(N(bK, bG[2]), 1), P(N(bL, bH[2]), 31)), N(O(N(bL, bH[2]), 1), P(N(bK, bG[2]), 31)), N(O(N(bK, bG[12]), 10), P(N(bL, bH[12]), 22)), N(O(N(bL, bH[12]), 10), P(N(bK, bG[12]), 22))
				local bM, aE = N(bK, bG[22]), N(bL, bH[22])
				bG[22], bH[22] = N(O(bM, 2), P(aE, 30)), N(O(aE, 2), P(bM, 30))
				bK = N(bG[27], O(bG[29], 1), P(bH[29], 31))
				bL = N(bH[27], O(bH[29], 1), P(bG[29], 31))
				bG[3], bH[3], bG[8], bH[8], bG[13], bH[13], bG[23], bH[23] = N(P(N(bK, bG[13]), 21), O(N(bL, bH[13]), 11)), N(P(N(bL, bH[13]), 21), O(N(bK, bG[13]), 11)), N(P(N(bK, bG[23]), 3), O(N(bL, bH[23]), 29)), N(P(N(bL, bH[23]), 3), O(N(bK, bG[23]), 29)), N(O(N(bK, bG[8]), 6), P(N(bL, bH[8]), 26)), N(O(N(bL, bH[8]), 6), P(N(bK, bG[8]), 26)), N(P(N(bK, bG[3]), 2), O(N(bL, bH[3]), 30)), N(P(N(bL, bH[3]), 2), O(N(bK, bG[3]), 30))
				bM, aE = N(bK, bG[18]), N(bL, bH[18])
				bG[18], bH[18] = N(O(bM, 15), P(aE, 17)), N(O(aE, 15), P(bM, 17))
				bK = N(bG[28], O(bG[30], 1), P(bH[30], 31))
				bL = N(bH[28], O(bH[30], 1), P(bG[30], 31))
				bG[4], bH[4], bG[9], bH[9], bG[19], bH[19], bG[24], bH[24] = N(O(N(bK, bG[19]), 21), P(N(bL, bH[19]), 11)), N(O(N(bL, bH[19]), 21), P(N(bK, bG[19]), 11)), N(O(N(bK, bG[4]), 28), P(N(bL, bH[4]), 4)), N(O(N(bL, bH[4]), 28), P(N(bK, bG[4]), 4)), N(P(N(bK, bG[24]), 8), O(N(bL, bH[24]), 24)), N(P(N(bL, bH[24]), 8), O(N(bK, bG[24]), 24)), N(P(N(bK, bG[9]), 9), O(N(bL, bH[9]), 23)), N(P(N(bL, bH[9]), 9), O(N(bK, bG[9]), 23))
				bM, aE = N(bK, bG[14]), N(bL, bH[14])
				bG[14], bH[14] = N(O(bM, 25), P(aE, 7)), N(O(aE, 25), P(bM, 7))
				bK = N(bG[29], O(bG[26], 1), P(bH[26], 31))
				bL = N(bH[29], O(bH[26], 1), P(bG[26], 31))
				bG[5], bH[5], bG[15], bH[15], bG[20], bH[20], bG[25], bH[25] = N(O(N(bK, bG[25]), 14), P(N(bL, bH[25]), 18)), N(O(N(bL, bH[25]), 14), P(N(bK, bG[25]), 18)), N(O(N(bK, bG[20]), 8), P(N(bL, bH[20]), 24)), N(O(N(bL, bH[20]), 8), P(N(bK, bG[20]), 24)), N(O(N(bK, bG[5]), 27), P(N(bL, bH[5]), 5)), N(O(N(bL, bH[5]), 27), P(N(bK, bG[5]), 5)), N(P(N(bK, bG[15]), 25), O(N(bL, bH[15]), 7)), N(P(N(bL, bH[15]), 25), O(N(bK, bG[15]), 7))
				bM, aE = N(bK, bG[10]), N(bL, bH[10])
				bG[10], bH[10] = N(O(bM, 20), P(aE, 12)), N(O(aE, 20), P(bM, 12))
				bK = N(bG[30], O(bG[27], 1), P(bH[27], 31))
				bL = N(bH[30], O(bH[27], 1), P(bG[27], 31))
				bG[6], bH[6], bG[11], bH[11], bG[16], bH[16], bG[21], bH[21] = N(O(N(bK, bG[11]), 3), P(N(bL, bH[11]), 29)), N(O(N(bL, bH[11]), 3), P(N(bK, bG[11]), 29)), N(O(N(bK, bG[21]), 18), P(N(bL, bH[21]), 14)), N(O(N(bL, bH[21]), 18), P(N(bK, bG[21]), 14)), N(P(N(bK, bG[6]), 28), O(N(bL, bH[6]), 4)), N(P(N(bL, bH[6]), 28), O(N(bK, bG[6]), 4)), N(P(N(bK, bG[16]), 23), O(N(bL, bH[16]), 9)), N(P(N(bL, bH[16]), 23), O(N(bK, bG[16]), 9))
				bG[1], bH[1] = N(bK, bG[1]), N(bL, bH[1])
				bG[1], bG[2], bG[3], bG[4], bG[5] = N(bG[1], L(S(bG[2]), bG[3]), bI[b8]), N(bG[2], L(S(bG[3]), bG[4])), N(bG[3], L(S(bG[4]), bG[5])), N(bG[4], L(S(bG[5]), bG[1])), N(bG[5], L(S(bG[1]), bG[2]))
				bG[6], bG[7], bG[8], bG[9], bG[10] = N(bG[9], L(S(bG[10]), bG[6])), N(bG[10], L(S(bG[6]), bG[7])), N(bG[6], L(S(bG[7]), bG[8])), N(bG[7], L(S(bG[8]), bG[9])), N(bG[8], L(S(bG[9]), bG[10]))
				bG[11], bG[12], bG[13], bG[14], bG[15] = N(bG[12], L(S(bG[13]), bG[14])), N(bG[13], L(S(bG[14]), bG[15])), N(bG[14], L(S(bG[15]), bG[11])), N(bG[15], L(S(bG[11]), bG[12])), N(bG[11], L(S(bG[12]), bG[13]))
				bG[16], bG[17], bG[18], bG[19], bG[20] = N(bG[20], L(S(bG[16]), bG[17])), N(bG[16], L(S(bG[17]), bG[18])), N(bG[17], L(S(bG[18]), bG[19])), N(bG[18], L(S(bG[19]), bG[20])), N(bG[19], L(S(bG[20]), bG[16]))
				bG[21], bG[22], bG[23], bG[24], bG[25] = N(bG[23], L(S(bG[24]), bG[25])), N(bG[24], L(S(bG[25]), bG[21])), N(bG[25], L(S(bG[21]), bG[22])), N(bG[21], L(S(bG[22]), bG[23])), N(bG[22], L(S(bG[23]), bG[24]))
				bH[1], bH[2], bH[3], bH[4], bH[5] = N(bH[1], L(S(bH[2]), bH[3]), bJ[b8]), N(bH[2], L(S(bH[3]), bH[4])), N(bH[3], L(S(bH[4]), bH[5])), N(bH[4], L(S(bH[5]), bH[1])), N(bH[5], L(S(bH[1]), bH[2]))
				bH[6], bH[7], bH[8], bH[9], bH[10] = N(bH[9], L(S(bH[10]), bH[6])), N(bH[10], L(S(bH[6]), bH[7])), N(bH[6], L(S(bH[7]), bH[8])), N(bH[7], L(S(bH[8]), bH[9])), N(bH[8], L(S(bH[9]), bH[10]))
				bH[11], bH[12], bH[13], bH[14], bH[15] = N(bH[12], L(S(bH[13]), bH[14])), N(bH[13], L(S(bH[14]), bH[15])), N(bH[14], L(S(bH[15]), bH[11])), N(bH[15], L(S(bH[11]), bH[12])), N(bH[11], L(S(bH[12]), bH[13]))
				bH[16], bH[17], bH[18], bH[19], bH[20] = N(bH[20], L(S(bH[16]), bH[17])), N(bH[16], L(S(bH[17]), bH[18])), N(bH[17], L(S(bH[18]), bH[19])), N(bH[18], L(S(bH[19]), bH[20])), N(bH[19], L(S(bH[20]), bH[16]))
				bH[21], bH[22], bH[23], bH[24], bH[25] = N(bH[23], L(S(bH[24]), bH[25])), N(bH[24], L(S(bH[25]), bH[21])), N(bH[25], L(S(bH[21]), bH[22])), N(bH[21], L(S(bH[22]), bH[23])), N(bH[22], L(S(bH[23]), bH[24]))
			end
		end
	end
end

if K == "LJ" then
	function ab(aE, aF, aG, aC)
		local aH, aI = av, ah

		for aJ = aG, aG + aC - 1, 64 do
			for aK = 1, 16 do
				aJ = aJ + 4
				local aL, D, aM, aN = c(aF, aJ - 3, aJ)
				aH[aK] = M(O(aL, 24), O(D, 16), O(aM, 8), aN)
			end

			for aK = 17, 64 do
				local aL, D = aH[aK - 15], aH[aK - 2]
				aH[aK] = T(T(N(R(aL, 7), Q(aL, 14), P(aL, 3)) + N(Q(D, 15), Q(D, 13), P(D, 10))) + T(aH[aK - 7] + aH[aK - 16]))
			end

			local aL, D, aM, aN, aO, aP, aQ, aR = aE[1], aE[2], aE[3], aE[4], aE[5], aE[6], aE[7], aE[8]

			for aK = 1, 64, 8 do
				local a6 = T(N(R(aO, 6), R(aO, 11), Q(aO, 7)) + N(aQ, L(aO, N(aP, aQ))) + aI[aK] + aH[aK] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(R(aO, 6), R(aO, 11), Q(aO, 7)) + N(aQ, L(aO, N(aP, aQ))) + aI[aK + 1] + aH[aK + 1] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(R(aO, 6), R(aO, 11), Q(aO, 7)) + N(aQ, L(aO, N(aP, aQ))) + aI[aK + 2] + aH[aK + 2] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(R(aO, 6), R(aO, 11), Q(aO, 7)) + N(aQ, L(aO, N(aP, aQ))) + aI[aK + 3] + aH[aK + 3] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(R(aO, 6), R(aO, 11), Q(aO, 7)) + N(aQ, L(aO, N(aP, aQ))) + aI[aK + 4] + aH[aK + 4] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(R(aO, 6), R(aO, 11), Q(aO, 7)) + N(aQ, L(aO, N(aP, aQ))) + aI[aK + 5] + aH[aK + 5] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(R(aO, 6), R(aO, 11), Q(aO, 7)) + N(aQ, L(aO, N(aP, aQ))) + aI[aK + 6] + aH[aK + 6] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
				a6 = T(N(R(aO, 6), R(aO, 11), Q(aO, 7)) + N(aQ, L(aO, N(aP, aQ))) + aI[aK + 7] + aH[aK + 7] + aR)
				aR, aQ, aP, aO = aQ, aP, aO, T(aN + a6)
				aN, aM, D, aL = aM, D, aL, T(N(L(aL, N(D, aM)), L(D, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10)) + a6)
			end

			aE[1], aE[2], aE[3], aE[4] = T(aL + aE[1]), T(D + aE[2]), T(aM + aE[3]), T(aN + aE[4])
			aE[5], aE[6], aE[7], aE[8] = T(aO + aE[5]), T(aP + aE[6]), T(aQ + aE[7]), T(aR + aE[8])
		end
	end

	local function bN(bg, bh, bl, bm, bB, bC, bO, bP)
		local bQ = bg % 2 ^ 32 + bl % 2 ^ 32 + bB % 2 ^ 32 + bO % 2 ^ 32
		local bR = bh + bm + bC + bP
		local by = T(bQ)
		local bz = T(bR + j(bQ / 2 ^ 32))

		return by, bz
	end

	if B == "x86" then
		function ac(bS, bT, aF, aG, aC)
			local aH, bU, bV = av, ag, ah

			for aJ = aG, aG + aC - 1, 128 do
				for aK = 1, 16 * 2 do
					aJ = aJ + 4
					local aL, D, aM, aN = c(aF, aJ - 3, aJ)
					aH[aK] = M(O(aL, 24), O(D, 16), O(aM, 8), aN)
				end

				for bW = 17 * 2, 80 * 2, 2 do
					local bg, bh = aH[bW - 30], aH[bW - 31]
					local bi = N(M(P(bg, 1), O(bh, 31)), M(P(bg, 8), O(bh, 24)), M(P(bg, 7), O(bh, 25)))
					local bj = N(M(P(bh, 1), O(bg, 31)), M(P(bh, 8), O(bg, 24)), P(bh, 7))
					local bl, bm = aH[bW - 4], aH[bW - 5]
					local bn = N(M(P(bl, 19), O(bm, 13)), M(O(bl, 3), P(bm, 29)), M(P(bl, 6), O(bm, 26)))
					local bo = N(M(P(bm, 19), O(bl, 13)), M(O(bm, 3), P(bl, 29)), P(bm, 6))
					aH[bW], aH[bW - 1] = bN(bi, bj, bn, bo, aH[bW - 14], aH[bW - 15], aH[bW - 32], aH[bW - 33])
				end

				local bg, bl, bB, bO, bq, bu, bw, bX = bS[1], bS[2], bS[3], bS[4], bS[5], bS[6], bS[7], bS[8]
				local bh, bm, bC, bP, br, bv, bx, bY = bT[1], bT[2], bT[3], bT[4], bT[5], bT[6], bT[7], bT[8]
				local bZ = 0

				for aK = 1, 80 do
					local bi = N(bw, L(bq, N(bu, bw)))
					local bj = N(bx, L(br, N(bv, bx)))
					local bn = N(M(P(bq, 14), O(br, 18)), M(P(bq, 18), O(br, 14)), M(O(bq, 23), P(br, 9)))
					local bo = N(M(P(br, 14), O(bq, 18)), M(P(br, 18), O(bq, 14)), M(O(br, 23), P(bq, 9)))
					local bQ = bn % 2 ^ 32 + bi % 2 ^ 32 + bX % 2 ^ 32 + bU[aK] + aH[2 * aK] % 2 ^ 32
					local b_, c0 = T(bQ), T(bo + bj + bY + bV[aK] + aH[2 * aK - 1] + j(bQ / 2 ^ 32))
					bZ = bZ + bZ
					bX, bY, bw, bx, bu, bv = M(bZ, bw), M(bZ, bx), M(bZ, bu), M(bZ, bv), M(bZ, bq), M(bZ, br)
					local bQ = b_ % 2 ^ 32 + bO % 2 ^ 32
					bq, br = T(bQ), T(c0 + bP + j(bQ / 2 ^ 32))
					bO, bP, bB, bC, bl, bm = M(bZ, bB), M(bZ, bC), M(bZ, bl), M(bZ, bm), M(bZ, bg), M(bZ, bh)
					bn = N(M(P(bl, 28), O(bm, 4)), M(O(bl, 30), P(bm, 2)), M(O(bl, 25), P(bm, 7)))
					bo = N(M(P(bm, 28), O(bl, 4)), M(O(bm, 30), P(bl, 2)), M(O(bm, 25), P(bl, 7)))
					bi = M(L(bO, bB), L(bl, N(bO, bB)))
					bj = M(L(bP, bC), L(bm, N(bP, bC)))
					local bQ = b_ % 2 ^ 32 + bi % 2 ^ 32 + bn % 2 ^ 32
					bg, bh = T(bQ), T(c0 + bj + bo + j(bQ / 2 ^ 32))
				end

				bS[1], bT[1] = bN(bS[1], bT[1], bg, bh, 0, 0, 0, 0)
				bS[2], bT[2] = bN(bS[2], bT[2], bl, bm, 0, 0, 0, 0)
				bS[3], bT[3] = bN(bS[3], bT[3], bB, bC, 0, 0, 0, 0)
				bS[4], bT[4] = bN(bS[4], bT[4], bO, bP, 0, 0, 0, 0)
				bS[5], bT[5] = bN(bS[5], bT[5], bq, br, 0, 0, 0, 0)
				bS[6], bT[6] = bN(bS[6], bT[6], bu, bv, 0, 0, 0, 0)
				bS[7], bT[7] = bN(bS[7], bT[7], bw, bx, 0, 0, 0, 0)
				bS[8], bT[8] = bN(bS[8], bT[8], bX, bY, 0, 0, 0, 0)
			end
		end
	else
		function ac(bS, bT, aF, aG, aC)
			local aH, bU, bV = av, ag, ah

			for aJ = aG, aG + aC - 1, 128 do
				for aK = 1, 16 * 2 do
					aJ = aJ + 4
					local aL, D, aM, aN = c(aF, aJ - 3, aJ)
					aH[aK] = M(O(aL, 24), O(D, 16), O(aM, 8), aN)
				end

				for bW = 17 * 2, 80 * 2, 2 do
					local bg, bh = aH[bW - 30], aH[bW - 31]
					local bi = N(M(P(bg, 1), O(bh, 31)), M(P(bg, 8), O(bh, 24)), M(P(bg, 7), O(bh, 25)))
					local bj = N(M(P(bh, 1), O(bg, 31)), M(P(bh, 8), O(bg, 24)), P(bh, 7))
					local bl, bm = aH[bW - 4], aH[bW - 5]
					local bn = N(M(P(bl, 19), O(bm, 13)), M(O(bl, 3), P(bm, 29)), M(P(bl, 6), O(bm, 26)))
					local bo = N(M(P(bm, 19), O(bl, 13)), M(O(bm, 3), P(bl, 29)), P(bm, 6))
					aH[bW], aH[bW - 1] = bN(bi, bj, bn, bo, aH[bW - 14], aH[bW - 15], aH[bW - 32], aH[bW - 33])
				end

				local bg, bl, bB, bO, bq, bu, bw, bX = bS[1], bS[2], bS[3], bS[4], bS[5], bS[6], bS[7], bS[8]
				local bh, bm, bC, bP, br, bv, bx, bY = bT[1], bT[2], bT[3], bT[4], bT[5], bT[6], bT[7], bT[8]

				for aK = 1, 80 do
					local bi = N(bw, L(bq, N(bu, bw)))
					local bj = N(bx, L(br, N(bv, bx)))
					local bn = N(M(P(bq, 14), O(br, 18)), M(P(bq, 18), O(br, 14)), M(O(bq, 23), P(br, 9)))
					local bo = N(M(P(br, 14), O(bq, 18)), M(P(br, 18), O(bq, 14)), M(O(br, 23), P(bq, 9)))
					local bQ = bn % 2 ^ 32 + bi % 2 ^ 32 + bX % 2 ^ 32 + bU[aK] + aH[2 * aK] % 2 ^ 32
					local b_, c0 = T(bQ), T(bo + bj + bY + bV[aK] + aH[2 * aK - 1] + j(bQ / 2 ^ 32))
					bX, bY, bw, bx, bu, bv = bw, bx, bu, bv, bq, br
					local bQ = b_ % 2 ^ 32 + bO % 2 ^ 32
					bq, br = T(bQ), T(c0 + bP + j(bQ / 2 ^ 32))
					bO, bP, bB, bC, bl, bm = bB, bC, bl, bm, bg, bh
					bn = N(M(P(bl, 28), O(bm, 4)), M(O(bl, 30), P(bm, 2)), M(O(bl, 25), P(bm, 7)))
					bo = N(M(P(bm, 28), O(bl, 4)), M(O(bm, 30), P(bl, 2)), M(O(bm, 25), P(bl, 7)))
					bi = M(L(bO, bB), L(bl, N(bO, bB)))
					bj = M(L(bP, bC), L(bm, N(bP, bC)))
					local bQ = b_ % 2 ^ 32 + bn % 2 ^ 32 + bi % 2 ^ 32
					bg, bh = T(bQ), T(c0 + bo + bj + j(bQ / 2 ^ 32))
				end

				bS[1], bT[1] = bN(bS[1], bT[1], bg, bh, 0, 0, 0, 0)
				bS[2], bT[2] = bN(bS[2], bT[2], bl, bm, 0, 0, 0, 0)
				bS[3], bT[3] = bN(bS[3], bT[3], bB, bC, 0, 0, 0, 0)
				bS[4], bT[4] = bN(bS[4], bT[4], bO, bP, 0, 0, 0, 0)
				bS[5], bT[5] = bN(bS[5], bT[5], bq, br, 0, 0, 0, 0)
				bS[6], bT[6] = bN(bS[6], bT[6], bu, bv, 0, 0, 0, 0)
				bS[7], bT[7] = bN(bS[7], bT[7], bw, bx, 0, 0, 0, 0)
				bS[8], bT[8] = bN(bS[8], bT[8], bX, bY, 0, 0, 0, 0)
			end
		end
	end

	function ad(aE, aF, aG, aC)
		local aH, aI = av, ap

		for aJ = aG, aG + aC - 1, 64 do
			for aK = 1, 16 do
				aJ = aJ + 4
				local aL, D, aM, aN = c(aF, aJ - 3, aJ)
				aH[aK] = M(O(aN, 24), O(aM, 16), O(D, 8), aL)
			end

			local aL, D, aM, aN = aE[1], aE[2], aE[3], aE[4]

			for aK = 1, 16, 4 do
				aL, aN, aM, D = aN, aM, D, T(Q(N(aN, L(D, N(aM, aN))) + aI[aK] + aH[aK] + aL, 7) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aN, L(D, N(aM, aN))) + aI[aK + 1] + aH[aK + 1] + aL, 12) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aN, L(D, N(aM, aN))) + aI[aK + 2] + aH[aK + 2] + aL, 17) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aN, L(D, N(aM, aN))) + aI[aK + 3] + aH[aK + 3] + aL, 22) + D)
			end

			for aK = 17, 32, 4 do
				local aQ = 5 * aK - 4
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, L(aN, N(D, aM))) + aI[aK] + aH[L(aQ, 15) + 1] + aL, 5) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, L(aN, N(D, aM))) + aI[aK + 1] + aH[L(aQ + 5, 15) + 1] + aL, 9) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, L(aN, N(D, aM))) + aI[aK + 2] + aH[L(aQ + 10, 15) + 1] + aL, 14) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, L(aN, N(D, aM))) + aI[aK + 3] + aH[L(aQ - 1, 15) + 1] + aL, 20) + D)
			end

			for aK = 33, 48, 4 do
				local aQ = 3 * aK + 2
				aL, aN, aM, D = aN, aM, D, T(Q(N(D, aM, aN) + aI[aK] + aH[L(aQ, 15) + 1] + aL, 4) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(D, aM, aN) + aI[aK + 1] + aH[L(aQ + 3, 15) + 1] + aL, 11) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(D, aM, aN) + aI[aK + 2] + aH[L(aQ + 6, 15) + 1] + aL, 16) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(D, aM, aN) + aI[aK + 3] + aH[L(aQ - 7, 15) + 1] + aL, 23) + D)
			end

			for aK = 49, 64, 4 do
				local aQ = aK * 7
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, M(D, S(aN))) + aI[aK] + aH[L(aQ - 7, 15) + 1] + aL, 6) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, M(D, S(aN))) + aI[aK + 1] + aH[L(aQ, 15) + 1] + aL, 10) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, M(D, S(aN))) + aI[aK + 2] + aH[L(aQ + 7, 15) + 1] + aL, 15) + D)
				aL, aN, aM, D = aN, aM, D, T(Q(N(aM, M(D, S(aN))) + aI[aK + 3] + aH[L(aQ - 2, 15) + 1] + aL, 21) + D)
			end

			aE[1], aE[2], aE[3], aE[4] = T(aL + aE[1]), T(D + aE[2]), T(aM + aE[3]), T(aN + aE[4])
		end
	end

	function ae(aE, aF, aG, aC)
		local aH = av

		for aJ = aG, aG + aC - 1, 64 do
			for aK = 1, 16 do
				aJ = aJ + 4
				local aL, D, aM, aN = c(aF, aJ - 3, aJ)
				aH[aK] = M(O(aL, 24), O(D, 16), O(aM, 8), aN)
			end

			for aK = 17, 80 do
				aH[aK] = Q(N(aH[aK - 3], aH[aK - 8], aH[aK - 14], aH[aK - 16]), 1)
			end

			local aL, D, aM, aN, aO = aE[1], aE[2], aE[3], aE[4], aE[5]

			for aK = 1, 20, 5 do
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(aN, L(D, N(aN, aM))) + aH[aK] + 0x5A827999 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(aN, L(D, N(aN, aM))) + aH[aK + 1] + 0x5A827999 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(aN, L(D, N(aN, aM))) + aH[aK + 2] + 0x5A827999 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(aN, L(D, N(aN, aM))) + aH[aK + 3] + 0x5A827999 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(aN, L(D, N(aN, aM))) + aH[aK + 4] + 0x5A827999 + aO)
			end

			for aK = 21, 40, 5 do
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK] + 0x6ED9EBA1 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 1] + 0x6ED9EBA1 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 2] + 0x6ED9EBA1 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 3] + 0x6ED9EBA1 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 4] + 0x6ED9EBA1 + aO)
			end

			for aK = 41, 60, 5 do
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(L(aN, N(D, aM)), L(D, aM)) + aH[aK] + 0x8F1BBCDC + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(L(aN, N(D, aM)), L(D, aM)) + aH[aK + 1] + 0x8F1BBCDC + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(L(aN, N(D, aM)), L(D, aM)) + aH[aK + 2] + 0x8F1BBCDC + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(L(aN, N(D, aM)), L(D, aM)) + aH[aK + 3] + 0x8F1BBCDC + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(L(aN, N(D, aM)), L(D, aM)) + aH[aK + 4] + 0x8F1BBCDC + aO)
			end

			for aK = 61, 80, 5 do
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK] + 0xCA62C1D6 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 1] + 0xCA62C1D6 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 2] + 0xCA62C1D6 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 3] + 0xCA62C1D6 + aO)
				aO, aN, aM, D, aL = aN, aM, R(D, 2), aL, T(Q(aL, 5) + N(D, aM, aN) + aH[aK + 4] + 0xCA62C1D6 + aO)
			end

			aE[1], aE[2], aE[3], aE[4], aE[5] = T(aL + aE[1]), T(D + aE[2]), T(aM + aE[3]), T(aN + aE[4]), T(aO + aE[5])
		end
	end
end

if K == "INT64" then
	ax = 4294967296
	ay = 4294967296
	au = 1
	as, at, V, ab, ac, ad, ae, af = load[[
local a,b,c,d,e,f=...local g,h=string.format,string.unpack;local function i(j)return g("%016x",j)end;local function k(j)return j~0xa5a5a5a5a5a5a5a5 end;local function l(j,m)return j~m end;local n={}local function o(p,q,r,s)local t,u=n,d;local v,w,x,y,z,A,B,C=p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8]for D=r+1,r+s,64 do t[1],t[2],t[3],t[4],t[5],t[6],t[7],t[8],t[9],t[10],t[11],t[12],t[13],t[14],t[15],t[16]=h(">I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4",q,D)for E=17,64 do local F=t[E-15]F=F<<32|F;local G=t[E-2]G=G<<32|G;t[E]=F>>7~(F>>18)~(F>>35)+G>>17~(G>>19)~(G>>42)+t[E-7]+t[E-16]&1<<32-1 end;local F,G,H,I,J,K,L,M=v,w,x,y,z,A,B,C;for E=1,64 do J=J<<32|(J&1<<32-1)local N=J>>6~(J>>11)~(J>>25)+L~(J&(K~L))+M+u[E]+t[E]M=L;L=K;K=J;J=N+I;I=H;H=G;G=F;F=F<<32|(F&1<<32-1)F=N+F~H&I~(F&H)+F>>2~(F>>13)~(F>>22)end;v=F+v;w=G+w;x=H+x;y=I+y;z=J+z;A=K+A;B=L+B;C=M+C end;p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8]=v,w,x,y,z,A,B,C end;local function O(p,P,q,r,s)local t,u=n,c;local v,w,x,y,z,A,B,C=p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8]for D=r+1,r+s,128 do t[1],t[2],t[3],t[4],t[5],t[6],t[7],t[8],t[9],t[10],t[11],t[12],t[13],t[14],t[15],t[16]=h(">i8i8i8i8i8i8i8i8i8i8i8i8i8i8i8i8",q,D)for E=17,80 do local F=t[E-15]local G=t[E-2]t[E]=F>>1~(F>>7)~(F>>8)~(F<<56)~(F<<63)+G>>6~(G>>19)~(G>>61)~(G<<3)~(G<<45)+t[E-7]+t[E-16]end;local F,G,H,I,J,K,L,M=v,w,x,y,z,A,B,C;for E=1,80 do local N=J>>14~(J>>18)~(J>>41)~(J<<23)~(J<<46)~(J<<50)+L~(J&(K~L))+M+u[E]+t[E]M=L;L=K;K=J;J=N+I;I=H;H=G;G=F;F=N+F~H&I~(F&H)+F>>28~(F>>34)~(F>>39)~(F<<25)~(F<<30)~(F<<36)end;v=F+v;w=G+w;x=H+x;y=I+y;z=J+z;A=K+A;B=L+B;C=M+C end;p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8]=v,w,x,y,z,A,B,C end;local function Q(p,q,r,s)local t,u,a=n,b,a;local v,w,x,y=p[1],p[2],p[3],p[4]for D=r+1,r+s,64 do t[1],t[2],t[3],t[4],t[5],t[6],t[7],t[8],t[9],t[10],t[11],t[12],t[13],t[14],t[15],t[16]=h("<I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4",q,D)local F,G,H,I=v,w,x,y;local R=32-7;for E=1,16 do local S=I~(G&(H~I))+F+u[E]+t[E]F=I;I=H;H=G;G=S<<32|(S&1<<32-1)>>R+G;R=a[R]end;R=32-5;for E=17,32 do local S=H~(I&(G~H))+F+u[E]+t[5*E-4&15+1]F=I;I=H;H=G;G=S<<32|(S&1<<32-1)>>R+G;R=a[R]end;R=32-4;for E=33,48 do local S=G~H~I+F+u[E]+t[3*E+2&15+1]F=I;I=H;H=G;G=S<<32|(S&1<<32-1)>>R+G;R=a[R]end;R=32-6;for E=49,64 do local S=H~(G|~I)+F+u[E]+t[E*7-7&15+1]F=I;I=H;H=G;G=S<<32|(S&1<<32-1)>>R+G;R=a[R]end;v=F+v;w=G+w;x=H+x;y=I+y end;p[1],p[2],p[3],p[4]=v,w,x,y end;local function T(p,q,r,s)local t=n;local v,w,x,y,z=p[1],p[2],p[3],p[4],p[5]for D=r+1,r+s,64 do t[1],t[2],t[3],t[4],t[5],t[6],t[7],t[8],t[9],t[10],t[11],t[12],t[13],t[14],t[15],t[16]=h(">I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4",q,D)for E=17,80 do local F=t[E-3]~t[E-8]~t[E-14]~t[E-16]t[E]=F<<32|F<<1>>32 end;local F,G,H,I,J=v,w,x,y,z;for E=1,20 do local N=F<<32|(F&1<<32-1)>>27+I~(G&(H~I))+0x5A827999+t[E]+J;J=I;I=H;H=G<<32|(G&1<<32-1)>>2;G=F;F=N end;for E=21,40 do local N=F<<32|(F&1<<32-1)>>27+G~H~I+0x6ED9EBA1+t[E]+J;J=I;I=H;H=G<<32|(G&1<<32-1)>>2;G=F;F=N end;for E=41,60 do local N=F<<32|(F&1<<32-1)>>27+G~H&I~(G&H)+0x8F1BBCDC+t[E]+J;J=I;I=H;H=G<<32|(G&1<<32-1)>>2;G=F;F=N end;for E=61,80 do local N=F<<32|(F&1<<32-1)>>27+G~H~I+0xCA62C1D6+t[E]+J;J=I;I=H;H=G<<32|(G&1<<32-1)>>2;G=F;F=N end;v=F+v;w=G+w;x=H+x;y=I+y;z=J+z end;p[1],p[2],p[3],p[4],p[5]=v,w,x,y,z end;local U=e("i8")local function V(W,P,q,r,s,X)local Y=f;local Z=X/8;local _=U[Z]for D=r+1,r+s,X do local a0={h(_,q,D)}for E=1,Z do W[E]=W[E]~a0[E]end;local a1,a2,a3,a4,a5,a6,a7,a8,a9,aa,ab,ac,ad,ae,af,ag,ah,ai,aj,ak,al,am,an,ao,ap=W[1],W[2],W[3],W[4],W[5],W[6],W[7],W[8],W[9],W[10],W[11],W[12],W[13],W[14],W[15],W[16],W[17],W[18],W[19],W[20],W[21],W[22],W[23],W[24],W[25]for aq=1,24 do local ar=a1~a6~ab~ag~al;local as=a2~a7~ac~ah~am;local at=a3~a8~ad~ai~an;local au=a4~a9~ae~aj~ao;local av=a5~aa~af~ak~ap;local aw=ar~(at<<1)~(at>>63)local ax=aw~a2;local ay=aw~a7;local az=aw~ac;local aA=aw~ah;local aB=aw~am;a2=ay<<44~(ay>>20)a7=aA<<45~(aA>>19)ac=ax<<1~(ax>>63)ah=az<<10~(az>>54)am=aB<<2~(aB>>62)aw=as~(au<<1)~(au>>63)ax=aw~a3;ay=aw~a8;az=aw~ad;aA=aw~ai;aB=aw~an;a3=az<<43~(az>>21)a8=aB<<61~(aB>>3)ad=ay<<6~(ay>>58)ai=aA<<15~(aA>>49)an=ax<<62~(ax>>2)aw=at~(av<<1)~(av>>63)ax=aw~a4;ay=aw~a9;az=aw~ae;aA=aw~aj;aB=aw~ao;a4=aA<<21~(aA>>43)a9=ax<<28~(ax>>36)ae=az<<25~(az>>39)aj=aB<<56~(aB>>8)ao=ay<<55~(ay>>9)aw=au~(ar<<1)~(ar>>63)ax=aw~a5;ay=aw~aa;az=aw~af;aA=aw~ak;aB=aw~ap;a5=aB<<14~(aB>>50)aa=ay<<20~(ay>>44)af=aA<<8~(aA>>56)ak=ax<<27~(ax>>37)ap=az<<39~(az>>25)aw=av~(as<<1)~(as>>63)ay=aw~a6;az=aw~ab;aA=aw~ag;aB=aw~al;a6=az<<3~(az>>61)ab=aB<<18~(aB>>46)ag=ay<<36~(ay>>28)al=aA<<41~(aA>>23)a1=aw~a1;a1,a2,a3,a4,a5=a1~(~a2&a3),a2~(~a3&a4),a3~(~a4&a5),a4~(~a5&a1),a5~(~a1&a2)a6,a7,a8,a9,aa=a9~(~aa&a6),aa~(~a6&a7),a6~(~a7&a8),a7~(~a8&a9),a8~(~a9&aa)ab,ac,ad,ae,af=ac~(~ad&ae),ad~(~ae&af),ae~(~af&ab),af~(~ab&ac),ab~(~ac&ad)ag,ah,ai,aj,ak=ak~(~ag&ah),ag~(~ah&ai),ah~(~ai&aj),ai~(~aj&ak),aj~(~ak&ag)al,am,an,ao,ap=an~(~ao&ap),ao~(~ap&al),ap~(~al&am),al~(~am&an),am~(~an&ao)a1=a1~Y[aq]end;W[1]=a1;W[2]=a2;W[3]=a3;W[4]=a4;W[5]=a5;W[6]=a6;W[7]=a7;W[8]=a8;W[9]=a9;W[10]=aa;W[11]=ab;W[12]=ac;W[13]=ad;W[14]=ae;W[15]=af;W[16]=ag;W[17]=ah;W[18]=ai;W[19]=aj;W[20]=ak;W[21]=al;W[22]=am;W[23]=an;W[24]=ao;W[25]=ap end end;return i,k,l,o,O,Q,T,V
   ]](ar, ap, ag, ah, az, ak)
end

if K == "INT32" then
	aw = 2 ^ 32

	function U(t)
		return i("%08x", t)
	end

	a9, V, ab, ac, ad, ae, af = load[[
      local a,b,c,d,e,f,g=...local h,i=string.unpack,math.floor;local function j(k)return k~0xA5A5A5A5 end;local function l(k,m)return k~m end;local n={}local function o(p,q,r,s)local t,u=n,d;local v,w,x,y,z,A,B,C=p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8]for D=r+1,r+s,64 do t[1],t[2],t[3],t[4],t[5],t[6],t[7],t[8],t[9],t[10],t[11],t[12],t[13],t[14],t[15],t[16]=h(">i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4",q,D)for E=17,64 do local F,G=t[E-15],t[E-2]t[E]=F>>7~(F<<25)~(F<<14)~(F>>18)~(F>>3)+G<<15~(G>>17)~(G<<13)~(G>>19)~(G>>10)+t[E-7]+t[E-16]end;local F,G,H,I,J,K,L,M=v,w,x,y,z,A,B,C;for E=1,64 do local N=J>>6~(J<<26)~(J>>11)~(J<<21)~(J>>25)~(J<<7)+L~(J&(K~L))+M+u[E]+t[E]M=L;L=K;K=J;J=N+I;I=H;H=G;G=F;F=N+F~H&I~(F&H)+F>>2~(F<<30)~(F>>13)~(F<<19)~(F<<10)~(F>>22)end;v=F+v;w=G+w;x=H+x;y=I+y;z=J+z;A=K+A;B=L+B;C=M+C end;p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8]=v,w,x,y,z,A,B,C end;local function O(P,Q,q,r,s)local i,t,R,S=i,n,c,d;local T,U,V,W,X,Y,Z,_=P[1],P[2],P[3],P[4],P[5],P[6],P[7],P[8]local a0,a1,a2,a3,a4,a5,a6,a7=Q[1],Q[2],Q[3],Q[4],Q[5],Q[6],Q[7],Q[8]for D=r+1,r+s,128 do t[1],t[2],t[3],t[4],t[5],t[6],t[7],t[8],t[9],t[10],t[11],t[12],t[13],t[14],t[15],t[16],t[17],t[18],t[19],t[20],t[21],t[22],t[23],t[24],t[25],t[26],t[27],t[28],t[29],t[30],t[31],t[32]=h(">i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4",q,D)for a8=17*2,80*2,2 do local a9,aa,ab,ac=t[a8-30],t[a8-31],t[a8-4],t[a8-5]local ad=a9>>1~(aa<<31)~(a9>>8)~(aa<<24)~(a9>>7)~(aa<<25)%2^32+ab>>19~(ac<<13)~(ab<<3)~(ac>>29)~(ab>>6)~(ac<<26)%2^32+t[a8-14]%2^32+t[a8-32]%2^32;t[a8-1]=aa>>1~(a9<<31)~(aa>>8)~(a9<<24)~(aa>>7)+ac>>19~(ab<<13)~(ac<<3)~(ab>>29)~(ac>>6)+t[a8-15]+t[a8-33]+i(ad/2^32)t[a8]=0|(ad+2^31)%2^32-2^31 end;local a9,ab,ae,af,ag,ah,ai,aj=T,U,V,W,X,Y,Z,_;local aa,ac,ak,al,am,an,ao,ap=a0,a1,a2,a3,a4,a5,a6,a7;for E=1,80 do local a8=2*E;local aq=ag>>14~(am<<18)~(ag>>18)~(am<<14)~(ag<<23)~(am>>9)%2^32+ai~(ag&(ah~ai))%2^32+aj%2^32+R[E]+t[a8]%2^32;local ar=am>>14~(ag<<18)~(am>>18)~(ag<<14)~(am<<23)~(ag>>9)+ao~(am&(an~ao))+ap+S[E]+t[a8-1]+i(aq/2^32)aq=aq%2^32;aj=ai;ap=ao;ai=ah;ao=an;ah=ag;an=am;ag=aq+af%2^32;am=ar+al+i(ag/2^32)ag=0|(ag+2^31)%2^32-2^31;af=ae;al=ak;ae=ab;ak=ac;ab=a9;ac=aa;aq=aq+af&ae~(ab&(af~ae))%2^32+ab>>28~(ac<<4)~(ab<<30)~(ac>>2)~(ab<<25)~(ac>>7)%2^32;aa=ar+al&ak~(ac&(al~ak))+ac>>28~(ab<<4)~(ac<<30)~(ab>>2)~(ac<<25)~(ab>>7)+i(aq/2^32)a9=0|(aq+2^31)%2^32-2^31 end;a9=T%2^32+a9%2^32;a0=a0+aa+i(a9/2^32)T=0|(a9+2^31)%2^32-2^31;a9=U%2^32+ab%2^32;a1=a1+ac+i(a9/2^32)U=0|(a9+2^31)%2^32-2^31;a9=V%2^32+ae%2^32;a2=a2+ak+i(a9/2^32)V=0|(a9+2^31)%2^32-2^31;a9=W%2^32+af%2^32;a3=a3+al+i(a9/2^32)W=0|(a9+2^31)%2^32-2^31;a9=X%2^32+ag%2^32;a4=a4+am+i(a9/2^32)X=0|(a9+2^31)%2^32-2^31;a9=Y%2^32+ah%2^32;a5=a5+an+i(a9/2^32)Y=0|(a9+2^31)%2^32-2^31;a9=Z%2^32+ai%2^32;a6=a6+ao+i(a9/2^32)Z=0|(a9+2^31)%2^32-2^31;a9=_%2^32+aj%2^32;a7=a7+ap+i(a9/2^32)_=0|(a9+2^31)%2^32-2^31 end;P[1],P[2],P[3],P[4],P[5],P[6],P[7],P[8]=T,U,V,W,X,Y,Z,_;Q[1],Q[2],Q[3],Q[4],Q[5],Q[6],Q[7],Q[8]=a0,a1,a2,a3,a4,a5,a6,a7 end;local function as(p,q,r,s)local t,u,a=n,b,a;local v,w,x,y=p[1],p[2],p[3],p[4]for D=r+1,r+s,64 do t[1],t[2],t[3],t[4],t[5],t[6],t[7],t[8],t[9],t[10],t[11],t[12],t[13],t[14],t[15],t[16]=h("<i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4",q,D)local F,G,H,I=v,w,x,y;local at=32-7;for E=1,16 do local au=I~(G&(H~I))+F+u[E]+t[E]F=I;I=H;H=G;G=au<<32-at|(au>>at)+G;at=a[at]end;at=32-5;for E=17,32 do local au=H~(I&(G~H))+F+u[E]+t[5*E-4&15+1]F=I;I=H;H=G;G=au<<32-at|(au>>at)+G;at=a[at]end;at=32-4;for E=33,48 do local au=G~H~I+F+u[E]+t[3*E+2&15+1]F=I;I=H;H=G;G=au<<32-at|(au>>at)+G;at=a[at]end;at=32-6;for E=49,64 do local au=H~(G|~I)+F+u[E]+t[E*7-7&15+1]F=I;I=H;H=G;G=au<<32-at|(au>>at)+G;at=a[at]end;v=F+v;w=G+w;x=H+x;y=I+y end;p[1],p[2],p[3],p[4]=v,w,x,y end;local function av(p,q,r,s)local t=n;local v,w,x,y,z=p[1],p[2],p[3],p[4],p[5]for D=r+1,r+s,64 do t[1],t[2],t[3],t[4],t[5],t[6],t[7],t[8],t[9],t[10],t[11],t[12],t[13],t[14],t[15],t[16]=h(">i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4i4",q,D)for E=17,80 do local F=t[E-3]~t[E-8]~t[E-14]~t[E-16]t[E]=F<<1~(F>>31)end;local F,G,H,I,J=v,w,x,y,z;for E=1,20 do local N=F<<5~(F>>27)+I~(G&(H~I))+0x5A827999+t[E]+J;J=I;I=H;H=G<<30~(G>>2)G=F;F=N end;for E=21,40 do local N=F<<5~(F>>27)+G~H~I+0x6ED9EBA1+t[E]+J;J=I;I=H;H=G<<30~(G>>2)G=F;F=N end;for E=41,60 do local N=F<<5~(F>>27)+G~H&I~(G&H)+0x8F1BBCDC+t[E]+J;J=I;I=H;H=G<<30~(G>>2)G=F;F=N end;for E=61,80 do local N=F<<5~(F>>27)+G~H~I+0xCA62C1D6+t[E]+J;J=I;I=H;H=G<<30~(G>>2)G=F;F=N end;v=F+v;w=G+w;x=H+x;y=I+y;z=J+z end;p[1],p[2],p[3],p[4],p[5]=v,w,x,y,z end;local aw=e("i4i4")local function ax(ay,az,q,r,s,aA)local aB,aC=f,g;local aD=aA/8;local aE=aw[aD]for D=r+1,r+s,aA do local aF={h(aE,q,D)}for E=1,aD do ay[E]=ay[E]~aF[2*E-1]az[E]=az[E]~aF[2*E]end;local aG,aH,aI,aJ,aK,aL,aM,aN,aO,aP,aQ,aR,aS,aT,aU,aV,aW,aX,aY,aZ,a_,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,ba,bb,bc,bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs=ay[1],az[1],ay[2],az[2],ay[3],az[3],ay[4],az[4],ay[5],az[5],ay[6],az[6],ay[7],az[7],ay[8],az[8],ay[9],az[9],ay[10],az[10],ay[11],az[11],ay[12],az[12],ay[13],az[13],ay[14],az[14],ay[15],az[15],ay[16],az[16],ay[17],az[17],ay[18],az[18],ay[19],az[19],ay[20],az[20],ay[21],az[21],ay[22],az[22],ay[23],az[23],ay[24],az[24],ay[25],az[25]for bt=1,24 do local bu=aG~aQ~a_~b9~bj;local bv=aH~aR~b0~ba~bk;local bw=aI~aS~b1~bb~bl;local bx=aJ~aT~b2~bc~bm;local by=aK~aU~b3~bd~bn;local bz=aL~aV~b4~be~bo;local bA=aM~aW~b5~bf~bp;local bB=aN~aX~b6~bg~bq;local bC=aO~aY~b7~bh~br;local bD=aP~aZ~b8~bi~bs;local bE=bu~(by<<1)~(bz>>31)local bF=bv~(bz<<1)~(by>>31)local bG=bE~aI;local bH=bF~aJ;local bI=bE~aS;local bJ=bF~aT;local bK=bE~b1;local bL=bF~b2;local bM=bE~bb;local bN=bF~bc;local bO=bE~bl;local bP=bF~bm;aI=bI>>20~(bJ<<12)aJ=bJ>>20~(bI<<12)aS=bM>>19~(bN<<13)aT=bN>>19~(bM<<13)b1=bG<<1~(bH>>31)b2=bH<<1~(bG>>31)bb=bK<<10~(bL>>22)bc=bL<<10~(bK>>22)bl=bO<<2~(bP>>30)bm=bP<<2~(bO>>30)bE=bw~(bA<<1)~(bB>>31)bF=bx~(bB<<1)~(bA>>31)bG=bE~aK;bH=bF~aL;bI=bE~aU;bJ=bF~aV;bK=bE~b3;bL=bF~b4;bM=bE~bd;bN=bF~be;bO=bE~bn;bP=bF~bo;aK=bK>>21~(bL<<11)aL=bL>>21~(bK<<11)aU=bO>>3~(bP<<29)aV=bP>>3~(bO<<29)b3=bI<<6~(bJ>>26)b4=bJ<<6~(bI>>26)bd=bM<<15~(bN>>17)be=bN<<15~(bM>>17)bn=bG>>2~(bH<<30)bo=bH>>2~(bG<<30)bE=by~(bC<<1)~(bD>>31)bF=bz~(bD<<1)~(bC>>31)bG=bE~aM;bH=bF~aN;bI=bE~aW;bJ=bF~aX;bK=bE~b5;bL=bF~b6;bM=bE~bf;bN=bF~bg;bO=bE~bp;bP=bF~bq;aM=bM<<21~(bN>>11)aN=bN<<21~(bM>>11)aW=bG<<28~(bH>>4)aX=bH<<28~(bG>>4)b5=bK<<25~(bL>>7)b6=bL<<25~(bK>>7)bf=bO>>8~(bP<<24)bg=bP>>8~(bO<<24)bp=bI>>9~(bJ<<23)bq=bJ>>9~(bI<<23)bE=bA~(bu<<1)~(bv>>31)bF=bB~(bv<<1)~(bu>>31)bG=bE~aO;bH=bF~aP;bI=bE~aY;bJ=bF~aZ;bK=bE~b7;bL=bF~b8;bM=bE~bh;bN=bF~bi;bO=bE~br;bP=bF~bs;aO=bO<<14~(bP>>18)aP=bP<<14~(bO>>18)aY=bI<<20~(bJ>>12)aZ=bJ<<20~(bI>>12)b7=bM<<8~(bN>>24)b8=bN<<8~(bM>>24)bh=bG<<27~(bH>>5)bi=bH<<27~(bG>>5)br=bK>>25~(bL<<7)bs=bL>>25~(bK<<7)bE=bC~(bw<<1)~(bx>>31)bF=bD~(bx<<1)~(bw>>31)bI=bE~aQ;bJ=bF~aR;bK=bE~a_;bL=bF~b0;bM=bE~b9;bN=bF~ba;bO=bE~bj;bP=bF~bk;aQ=bK<<3~(bL>>29)aR=bL<<3~(bK>>29)a_=bO<<18~(bP>>14)b0=bP<<18~(bO>>14)b9=bI>>28~(bJ<<4)ba=bJ>>28~(bI<<4)bj=bM>>23~(bN<<9)bk=bN>>23~(bM<<9)aG=bE~aG;aH=bF~aH;aG,aI,aK,aM,aO=aG~(~aI&aK),aI~(~aK&aM),aK~(~aM&aO),aM~(~aO&aG),aO~(~aG&aI)aH,aJ,aL,aN,aP=aH~(~aJ&aL),aJ~(~aL&aN),aL~(~aN&aP),aN~(~aP&aH),aP~(~aH&aJ)aQ,aS,aU,aW,aY=aW~(~aY&aQ),aY~(~aQ&aS),aQ~(~aS&aU),aS~(~aU&aW),aU~(~aW&aY)aR,aT,aV,aX,aZ=aX~(~aZ&aR),aZ~(~aR&aT),aR~(~aT&aV),aT~(~aV&aX),aV~(~aX&aZ)a_,b1,b3,b5,b7=b1~(~b3&b5),b3~(~b5&b7),b5~(~b7&a_),b7~(~a_&b1),a_~(~b1&b3)b0,b2,b4,b6,b8=b2~(~b4&b6),b4~(~b6&b8),b6~(~b8&b0),b8~(~b0&b2),b0~(~b2&b4)b9,bb,bd,bf,bh=bh~(~b9&bb),b9~(~bb&bd),bb~(~bd&bf),bd~(~bf&bh),bf~(~bh&b9)ba,bc,be,bg,bi=bi~(~ba&bc),ba~(~bc&be),bc~(~be&bg),be~(~bg&bi),bg~(~bi&ba)bj,bl,bn,bp,br=bn~(~bp&br),bp~(~br&bj),br~(~bj&bl),bj~(~bl&bn),bl~(~bn&bp)bk,bm,bo,bq,bs=bo~(~bq&bs),bq~(~bs&bk),bs~(~bk&bm),bk~(~bm&bo),bm~(~bo&bq)aG=aG~aB[bt]aH=aH~aC[bt]end;ay[1]=aG;az[1]=aH;ay[2]=aI;az[2]=aJ;ay[3]=aK;az[3]=aL;ay[4]=aM;az[4]=aN;ay[5]=aO;az[5]=aP;ay[6]=aQ;az[6]=aR;ay[7]=aS;az[7]=aT;ay[8]=aU;az[8]=aV;ay[9]=aW;az[9]=aX;ay[10]=aY;az[10]=aZ;ay[11]=a_;az[11]=b0;ay[12]=b1;az[12]=b2;ay[13]=b3;az[13]=b4;ay[14]=b5;az[14]=b6;ay[15]=b7;az[15]=b8;ay[16]=b9;az[16]=ba;ay[17]=bb;az[17]=bc;ay[18]=bd;az[18]=be;ay[19]=bf;az[19]=bg;ay[20]=bh;az[20]=bi;ay[21]=bj;az[21]=bk;ay[22]=bl;az[22]=bm;ay[23]=bn;az[23]=bo;ay[24]=bp;az[24]=bq;ay[25]=br;az[25]=bs end end;return j,l,o,O,as,av,ax
   ]](ar, ap, ag, ah, az, ak, al)
end

if K == "LIB32" or K == "EMUL" then
	function ab(aE, aF, aG, aC)
		local aH, aI = av, ah
		local c1, c2, c3, c4, c5, c6, c7, c8 = aE[1], aE[2], aE[3], aE[4], aE[5], aE[6], aE[7], aE[8]

		for aJ = aG, aG + aC - 1, 64 do
			for aK = 1, 16 do
				aJ = aJ + 4
				local aL, D, aM, aN = c(aF, aJ - 3, aJ)
				aH[aK] = ((aL * 256 + D) * 256 + aM) * 256 + aN
			end

			for aK = 17, 64 do
				local aL, D = aH[aK - 15], aH[aK - 2]
				aH[aK] = N(R(aL, 7), Q(aL, 14), P(aL, 3)) + N(Q(D, 15), Q(D, 13), P(D, 10)) + aH[aK - 7] + aH[aK - 16]
			end

			local aL, D, aM, aN, aO, aP, aQ, aR = c1, c2, c3, c4, c5, c6, c7, c8

			for aK = 1, 64 do
				local a6 = N(R(aO, 6), R(aO, 11), Q(aO, 7)) + L(aO, aP) + L(-1 - aO, aQ) + aR + aI[aK] + aH[aK]
				aR = aQ
				aQ = aP
				aP = aO
				aO = a6 + aN
				aN = aM
				aM = D
				D = aL
				aL = a6 + L(aN, aM) + L(aL, N(aN, aM)) + N(R(aL, 2), R(aL, 13), Q(aL, 10))
			end

			c1, c2, c3, c4 = (aL + c1) % 4294967296, (D + c2) % 4294967296, (aM + c3) % 4294967296, (aN + c4) % 4294967296
			c5, c6, c7, c8 = (aO + c5) % 4294967296, (aP + c6) % 4294967296, (aQ + c7) % 4294967296, (aR + c8) % 4294967296
		end

		aE[1], aE[2], aE[3], aE[4], aE[5], aE[6], aE[7], aE[8] = c1, c2, c3, c4, c5, c6, c7, c8
	end

	function ac(bS, bT, aF, aG, aC)
		local aH, bU, bV = av, ag, ah
		local c9, ca, cb, cc, cd, ce, cf, cg = bS[1], bS[2], bS[3], bS[4], bS[5], bS[6], bS[7], bS[8]
		local ch, ci, cj, ck, cl, cm, cn, co = bT[1], bT[2], bT[3], bT[4], bT[5], bT[6], bT[7], bT[8]

		for aJ = aG, aG + aC - 1, 128 do
			for aK = 1, 16 * 2 do
				aJ = aJ + 4
				local aL, D, aM, aN = c(aF, aJ - 3, aJ)
				aH[aK] = ((aL * 256 + D) * 256 + aM) * 256 + aN
			end

			for bW = 17 * 2, 80 * 2, 2 do
				local bg, bh, bl, bm = aH[bW - 30], aH[bW - 31], aH[bW - 4], aH[bW - 5]
				local cp = N(P(bg, 1) + O(bh, 31), P(bg, 8) + O(bh, 24), P(bg, 7) + O(bh, 25)) % 4294967296 + N(P(bl, 19) + O(bm, 13), O(bl, 3) + P(bm, 29), P(bl, 6) + O(bm, 26)) % 4294967296 + aH[bW - 14] + aH[bW - 32]
				local cq = cp % 4294967296
				aH[bW - 1] = N(P(bh, 1) + O(bg, 31), P(bh, 8) + O(bg, 24), P(bh, 7)) + N(P(bm, 19) + O(bl, 13), O(bm, 3) + P(bl, 29), P(bm, 6)) + aH[bW - 15] + aH[bW - 33] + (cp - cq) / 4294967296
				aH[bW] = cq
			end

			local bg, bl, bB, bO, bq, bu, bw, bX = c9, ca, cb, cc, cd, ce, cf, cg
			local bh, bm, bC, bP, br, bv, bx, bY = ch, ci, cj, ck, cl, cm, cn, co

			for aK = 1, 80 do
				local bW = 2 * aK
				local cp = N(P(bq, 14) + O(br, 18), P(bq, 18) + O(br, 14), O(bq, 23) + P(br, 9)) % 4294967296 + (L(bq, bu) + L(-1 - bq, bw)) % 4294967296 + bX + bU[aK] + aH[bW]
				local b_ = cp % 4294967296
				local c0 = N(P(br, 14) + O(bq, 18), P(br, 18) + O(bq, 14), O(br, 23) + P(bq, 9)) + L(br, bv) + L(-1 - br, bx) + bY + bV[aK] + aH[bW - 1] + (cp - b_) / 4294967296
				bX = bw
				bY = bx
				bw = bu
				bx = bv
				bu = bq
				bv = br
				cp = b_ + bO
				bq = cp % 4294967296
				br = c0 + bP + (cp - bq) / 4294967296
				bO = bB
				bP = bC
				bB = bl
				bC = bm
				bl = bg
				bm = bh
				cp = b_ + (L(bO, bB) + L(bl, N(bO, bB))) % 4294967296 + N(P(bl, 28) + O(bm, 4), O(bl, 30) + P(bm, 2), O(bl, 25) + P(bm, 7)) % 4294967296
				bg = cp % 4294967296
				bh = c0 + L(bP, bC) + L(bm, N(bP, bC)) + N(P(bm, 28) + O(bl, 4), O(bm, 30) + P(bl, 2), O(bm, 25) + P(bl, 7)) + (cp - bg) / 4294967296
			end

			bg = c9 + bg
			c9 = bg % 4294967296
			ch = (ch + bh + (bg - c9) / 4294967296) % 4294967296
			bg = ca + bl
			ca = bg % 4294967296
			ci = (ci + bm + (bg - ca) / 4294967296) % 4294967296
			bg = cb + bB
			cb = bg % 4294967296
			cj = (cj + bC + (bg - cb) / 4294967296) % 4294967296
			bg = cc + bO
			cc = bg % 4294967296
			ck = (ck + bP + (bg - cc) / 4294967296) % 4294967296
			bg = cd + bq
			cd = bg % 4294967296
			cl = (cl + br + (bg - cd) / 4294967296) % 4294967296
			bg = ce + bu
			ce = bg % 4294967296
			cm = (cm + bv + (bg - ce) / 4294967296) % 4294967296
			bg = cf + bw
			cf = bg % 4294967296
			cn = (cn + bx + (bg - cf) / 4294967296) % 4294967296
			bg = cg + bX
			cg = bg % 4294967296
			co = (co + bY + (bg - cg) / 4294967296) % 4294967296
		end

		bS[1], bS[2], bS[3], bS[4], bS[5], bS[6], bS[7], bS[8] = c9, ca, cb, cc, cd, ce, cf, cg
		bT[1], bT[2], bT[3], bT[4], bT[5], bT[6], bT[7], bT[8] = ch, ci, cj, ck, cl, cm, cn, co
	end

	function ad(aE, aF, aG, aC)
		local aH, aI, ar = av, ap, ar
		local c1, c2, c3, c4 = aE[1], aE[2], aE[3], aE[4]

		for aJ = aG, aG + aC - 1, 64 do
			for aK = 1, 16 do
				aJ = aJ + 4
				local aL, D, aM, aN = c(aF, aJ - 3, aJ)
				aH[aK] = ((aN * 256 + aM) * 256 + D) * 256 + aL
			end

			local aL, D, aM, aN = c1, c2, c3, c4
			local cr = 32 - 7

			for aK = 1, 16 do
				local cs = R(L(D, aM) + L(-1 - D, aN) + aL + aI[aK] + aH[aK], cr) + D
				cr = ar[cr]
				aL = aN
				aN = aM
				aM = D
				D = cs
			end

			cr = 32 - 5

			for aK = 17, 32 do
				local cs = R(L(aN, D) + L(-1 - aN, aM) + aL + aI[aK] + aH[(5 * aK - 4) % 16 + 1], cr) + D
				cr = ar[cr]
				aL = aN
				aN = aM
				aM = D
				D = cs
			end

			cr = 32 - 4

			for aK = 33, 48 do
				local cs = R(N(N(D, aM), aN) + aL + aI[aK] + aH[(3 * aK + 2) % 16 + 1], cr) + D
				cr = ar[cr]
				aL = aN
				aN = aM
				aM = D
				D = cs
			end

			cr = 32 - 6

			for aK = 49, 64 do
				local cs = R(N(aM, M(D, -1 - aN)) + aL + aI[aK] + aH[(aK * 7 - 7) % 16 + 1], cr) + D
				cr = ar[cr]
				aL = aN
				aN = aM
				aM = D
				D = cs
			end

			c1 = (aL + c1) % 4294967296
			c2 = (D + c2) % 4294967296
			c3 = (aM + c3) % 4294967296
			c4 = (aN + c4) % 4294967296
		end

		aE[1], aE[2], aE[3], aE[4] = c1, c2, c3, c4
	end

	function ae(aE, aF, aG, aC)
		local aH = av
		local c1, c2, c3, c4, c5 = aE[1], aE[2], aE[3], aE[4], aE[5]

		for aJ = aG, aG + aC - 1, 64 do
			for aK = 1, 16 do
				aJ = aJ + 4
				local aL, D, aM, aN = c(aF, aJ - 3, aJ)
				aH[aK] = ((aL * 256 + D) * 256 + aM) * 256 + aN
			end

			for aK = 17, 80 do
				aH[aK] = Q(N(aH[aK - 3], aH[aK - 8], aH[aK - 14], aH[aK - 16]), 1)
			end

			local aL, D, aM, aN, aO = c1, c2, c3, c4, c5

			for aK = 1, 20 do
				local a6 = Q(aL, 5) + L(D, aM) + L(-1 - D, aN) + 0x5A827999 + aH[aK] + aO
				aO = aN
				aN = aM
				aM = R(D, 2)
				D = aL
				aL = a6
			end

			for aK = 21, 40 do
				local a6 = Q(aL, 5) + N(D, aM, aN) + 0x6ED9EBA1 + aH[aK] + aO
				aO = aN
				aN = aM
				aM = R(D, 2)
				D = aL
				aL = a6
			end

			for aK = 41, 60 do
				local a6 = Q(aL, 5) + L(aN, aM) + L(D, N(aN, aM)) + 0x8F1BBCDC + aH[aK] + aO
				aO = aN
				aN = aM
				aM = R(D, 2)
				D = aL
				aL = a6
			end

			for aK = 61, 80 do
				local a6 = Q(aL, 5) + N(D, aM, aN) + 0xCA62C1D6 + aH[aK] + aO
				aO = aN
				aN = aM
				aM = R(D, 2)
				D = aL
				aL = a6
			end

			c1 = (aL + c1) % 4294967296
			c2 = (D + c2) % 4294967296
			c3 = (aM + c3) % 4294967296
			c4 = (aN + c4) % 4294967296
			c5 = (aO + c5) % 4294967296
		end

		aE[1], aE[2], aE[3], aE[4], aE[5] = c1, c2, c3, c4, c5
	end

	function af(bG, bH, aF, aG, aC, b5)
		local bI, bJ = ak, al
		local b7 = b5 / 8

		for aJ = aG, aG + aC - 1, b5 do
			for aK = 1, b7 do
				local aL, D, aM, aN = c(aF, aJ + 1, aJ + 4)
				bG[aK] = N(bG[aK], ((aN * 256 + aM) * 256 + D) * 256 + aL)
				aJ = aJ + 8
				aL, D, aM, aN = c(aF, aJ - 3, aJ)
				bH[aK] = N(bH[aK], ((aN * 256 + aM) * 256 + D) * 256 + aL)
			end

			local ct, cu, cv, cw, cx, cy, cz, cA, cB, cC, cD, cE, cF, cG, cH, cI, cJ, cK, cL, cM, cN, cO, cP, cQ, cR, cS, cT, cU, cV, cW, cX, cY, cZ, c_, d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, da, db, dc, dd, de, df = bG[1], bH[1], bG[2], bH[2], bG[3], bH[3], bG[4], bH[4], bG[5], bH[5], bG[6], bH[6], bG[7], bH[7], bG[8], bH[8], bG[9], bH[9], bG[10], bH[10], bG[11], bH[11], bG[12], bH[12], bG[13], bH[13], bG[14], bH[14], bG[15], bH[15], bG[16], bH[16], bG[17], bH[17], bG[18], bH[18], bG[19], bH[19], bG[20], bH[20], bG[21], bH[21], bG[22], bH[22], bG[23], bH[23], bG[24], bH[24], bG[25], bH[25]

			for b8 = 1, 24 do
				local dg = N(ct, cD, cN, cX, d6)
				local dh = N(cu, cE, cO, cY, d7)
				local di = N(cv, cF, cP, cZ, d8)
				local dj = N(cw, cG, cQ, c_, d9)
				local dk = N(cx, cH, cR, d0, da)
				local dl = N(cy, cI, cS, d1, db)
				local dm = N(cz, cJ, cT, d2, dc)
				local dn = N(cA, cK, cU, d3, dd)
				local dp = N(cB, cL, cV, d4, de)
				local dq = N(cC, cM, cW, d5, df)
				local bK = N(dg, dk * 2 + (dl % 2 ^ 32 - dl % 2 ^ 31) / 2 ^ 31)
				local bL = N(dh, dl * 2 + (dk % 2 ^ 32 - dk % 2 ^ 31) / 2 ^ 31)
				local dr = N(bK, cv)
				local ds = N(bL, cw)
				local dt = N(bK, cF)
				local du = N(bL, cG)
				local dv = N(bK, cP)
				local dw = N(bL, cQ)
				local dx = N(bK, cZ)
				local dy = N(bL, c_)
				local dz = N(bK, d8)
				local dA = N(bL, d9)
				cv = (dt % 2 ^ 32 - dt % 2 ^ 20) / 2 ^ 20 + du * 2 ^ 12
				cw = (du % 2 ^ 32 - du % 2 ^ 20) / 2 ^ 20 + dt * 2 ^ 12
				cF = (dx % 2 ^ 32 - dx % 2 ^ 19) / 2 ^ 19 + dy * 2 ^ 13
				cG = (dy % 2 ^ 32 - dy % 2 ^ 19) / 2 ^ 19 + dx * 2 ^ 13
				cP = dr * 2 + (ds % 2 ^ 32 - ds % 2 ^ 31) / 2 ^ 31
				cQ = ds * 2 + (dr % 2 ^ 32 - dr % 2 ^ 31) / 2 ^ 31
				cZ = dv * 2 ^ 10 + (dw % 2 ^ 32 - dw % 2 ^ 22) / 2 ^ 22
				c_ = dw * 2 ^ 10 + (dv % 2 ^ 32 - dv % 2 ^ 22) / 2 ^ 22
				d8 = dz * 2 ^ 2 + (dA % 2 ^ 32 - dA % 2 ^ 30) / 2 ^ 30
				d9 = dA * 2 ^ 2 + (dz % 2 ^ 32 - dz % 2 ^ 30) / 2 ^ 30
				bK = N(di, dm * 2 + (dn % 2 ^ 32 - dn % 2 ^ 31) / 2 ^ 31)
				bL = N(dj, dn * 2 + (dm % 2 ^ 32 - dm % 2 ^ 31) / 2 ^ 31)
				dr = N(bK, cx)
				ds = N(bL, cy)
				dt = N(bK, cH)
				du = N(bL, cI)
				dv = N(bK, cR)
				dw = N(bL, cS)
				dx = N(bK, d0)
				dy = N(bL, d1)
				dz = N(bK, da)
				dA = N(bL, db)
				cx = (dv % 2 ^ 32 - dv % 2 ^ 21) / 2 ^ 21 + dw * 2 ^ 11
				cy = (dw % 2 ^ 32 - dw % 2 ^ 21) / 2 ^ 21 + dv * 2 ^ 11
				cH = (dz % 2 ^ 32 - dz % 2 ^ 3) / 2 ^ 3 + dA * 2 ^ 29 % 2 ^ 32
				cI = (dA % 2 ^ 32 - dA % 2 ^ 3) / 2 ^ 3 + dz * 2 ^ 29 % 2 ^ 32
				cR = dt * 2 ^ 6 + (du % 2 ^ 32 - du % 2 ^ 26) / 2 ^ 26
				cS = du * 2 ^ 6 + (dt % 2 ^ 32 - dt % 2 ^ 26) / 2 ^ 26
				d0 = dx * 2 ^ 15 + (dy % 2 ^ 32 - dy % 2 ^ 17) / 2 ^ 17
				d1 = dy * 2 ^ 15 + (dx % 2 ^ 32 - dx % 2 ^ 17) / 2 ^ 17
				da = (dr % 2 ^ 32 - dr % 2 ^ 2) / 2 ^ 2 + ds * 2 ^ 30 % 2 ^ 32
				db = (ds % 2 ^ 32 - ds % 2 ^ 2) / 2 ^ 2 + dr * 2 ^ 30 % 2 ^ 32
				bK = N(dk, dp * 2 + (dq % 2 ^ 32 - dq % 2 ^ 31) / 2 ^ 31)
				bL = N(dl, dq * 2 + (dp % 2 ^ 32 - dp % 2 ^ 31) / 2 ^ 31)
				dr = N(bK, cz)
				ds = N(bL, cA)
				dt = N(bK, cJ)
				du = N(bL, cK)
				dv = N(bK, cT)
				dw = N(bL, cU)
				dx = N(bK, d2)
				dy = N(bL, d3)
				dz = N(bK, dc)
				dA = N(bL, dd)
				cz = dx * 2 ^ 21 % 2 ^ 32 + (dy % 2 ^ 32 - dy % 2 ^ 11) / 2 ^ 11
				cA = dy * 2 ^ 21 % 2 ^ 32 + (dx % 2 ^ 32 - dx % 2 ^ 11) / 2 ^ 11
				cJ = dr * 2 ^ 28 % 2 ^ 32 + (ds % 2 ^ 32 - ds % 2 ^ 4) / 2 ^ 4
				cK = ds * 2 ^ 28 % 2 ^ 32 + (dr % 2 ^ 32 - dr % 2 ^ 4) / 2 ^ 4
				cT = dv * 2 ^ 25 % 2 ^ 32 + (dw % 2 ^ 32 - dw % 2 ^ 7) / 2 ^ 7
				cU = dw * 2 ^ 25 % 2 ^ 32 + (dv % 2 ^ 32 - dv % 2 ^ 7) / 2 ^ 7
				d2 = (dz % 2 ^ 32 - dz % 2 ^ 8) / 2 ^ 8 + dA * 2 ^ 24 % 2 ^ 32
				d3 = (dA % 2 ^ 32 - dA % 2 ^ 8) / 2 ^ 8 + dz * 2 ^ 24 % 2 ^ 32
				dc = (dt % 2 ^ 32 - dt % 2 ^ 9) / 2 ^ 9 + du * 2 ^ 23 % 2 ^ 32
				dd = (du % 2 ^ 32 - du % 2 ^ 9) / 2 ^ 9 + dt * 2 ^ 23 % 2 ^ 32
				bK = N(dm, dg * 2 + (dh % 2 ^ 32 - dh % 2 ^ 31) / 2 ^ 31)
				bL = N(dn, dh * 2 + (dg % 2 ^ 32 - dg % 2 ^ 31) / 2 ^ 31)
				dr = N(bK, cB)
				ds = N(bL, cC)
				dt = N(bK, cL)
				du = N(bL, cM)
				dv = N(bK, cV)
				dw = N(bL, cW)
				dx = N(bK, d4)
				dy = N(bL, d5)
				dz = N(bK, de)
				dA = N(bL, df)
				cB = dz * 2 ^ 14 + (dA % 2 ^ 32 - dA % 2 ^ 18) / 2 ^ 18
				cC = dA * 2 ^ 14 + (dz % 2 ^ 32 - dz % 2 ^ 18) / 2 ^ 18
				cL = dt * 2 ^ 20 % 2 ^ 32 + (du % 2 ^ 32 - du % 2 ^ 12) / 2 ^ 12
				cM = du * 2 ^ 20 % 2 ^ 32 + (dt % 2 ^ 32 - dt % 2 ^ 12) / 2 ^ 12
				cV = dx * 2 ^ 8 + (dy % 2 ^ 32 - dy % 2 ^ 24) / 2 ^ 24
				cW = dy * 2 ^ 8 + (dx % 2 ^ 32 - dx % 2 ^ 24) / 2 ^ 24
				d4 = dr * 2 ^ 27 % 2 ^ 32 + (ds % 2 ^ 32 - ds % 2 ^ 5) / 2 ^ 5
				d5 = ds * 2 ^ 27 % 2 ^ 32 + (dr % 2 ^ 32 - dr % 2 ^ 5) / 2 ^ 5
				de = (dv % 2 ^ 32 - dv % 2 ^ 25) / 2 ^ 25 + dw * 2 ^ 7
				df = (dw % 2 ^ 32 - dw % 2 ^ 25) / 2 ^ 25 + dv * 2 ^ 7
				bK = N(dp, di * 2 + (dj % 2 ^ 32 - dj % 2 ^ 31) / 2 ^ 31)
				bL = N(dq, dj * 2 + (di % 2 ^ 32 - di % 2 ^ 31) / 2 ^ 31)
				dt = N(bK, cD)
				du = N(bL, cE)
				dv = N(bK, cN)
				dw = N(bL, cO)
				dx = N(bK, cX)
				dy = N(bL, cY)
				dz = N(bK, d6)
				dA = N(bL, d7)
				cD = dv * 2 ^ 3 + (dw % 2 ^ 32 - dw % 2 ^ 29) / 2 ^ 29
				cE = dw * 2 ^ 3 + (dv % 2 ^ 32 - dv % 2 ^ 29) / 2 ^ 29
				cN = dz * 2 ^ 18 + (dA % 2 ^ 32 - dA % 2 ^ 14) / 2 ^ 14
				cO = dA * 2 ^ 18 + (dz % 2 ^ 32 - dz % 2 ^ 14) / 2 ^ 14
				cX = (dt % 2 ^ 32 - dt % 2 ^ 28) / 2 ^ 28 + du * 2 ^ 4
				cY = (du % 2 ^ 32 - du % 2 ^ 28) / 2 ^ 28 + dt * 2 ^ 4
				d6 = (dx % 2 ^ 32 - dx % 2 ^ 23) / 2 ^ 23 + dy * 2 ^ 9
				d7 = (dy % 2 ^ 32 - dy % 2 ^ 23) / 2 ^ 23 + dx * 2 ^ 9
				ct = N(bK, ct)
				cu = N(bL, cu)
				ct, cv, cx, cz, cB = N(ct, L(-1 - cv, cx)), N(cv, L(-1 - cx, cz)), N(cx, L(-1 - cz, cB)), N(cz, L(-1 - cB, ct)), N(cB, L(-1 - ct, cv))
				cu, cw, cy, cA, cC = N(cu, L(-1 - cw, cy)), N(cw, L(-1 - cy, cA)), N(cy, L(-1 - cA, cC)), N(cA, L(-1 - cC, cu)), N(cC, L(-1 - cu, cw))
				cD, cF, cH, cJ, cL = N(cJ, L(-1 - cL, cD)), N(cL, L(-1 - cD, cF)), N(cD, L(-1 - cF, cH)), N(cF, L(-1 - cH, cJ)), N(cH, L(-1 - cJ, cL))
				cE, cG, cI, cK, cM = N(cK, L(-1 - cM, cE)), N(cM, L(-1 - cE, cG)), N(cE, L(-1 - cG, cI)), N(cG, L(-1 - cI, cK)), N(cI, L(-1 - cK, cM))
				cN, cP, cR, cT, cV = N(cP, L(-1 - cR, cT)), N(cR, L(-1 - cT, cV)), N(cT, L(-1 - cV, cN)), N(cV, L(-1 - cN, cP)), N(cN, L(-1 - cP, cR))
				cO, cQ, cS, cU, cW = N(cQ, L(-1 - cS, cU)), N(cS, L(-1 - cU, cW)), N(cU, L(-1 - cW, cO)), N(cW, L(-1 - cO, cQ)), N(cO, L(-1 - cQ, cS))
				cX, cZ, d0, d2, d4 = N(d4, L(-1 - cX, cZ)), N(cX, L(-1 - cZ, d0)), N(cZ, L(-1 - d0, d2)), N(d0, L(-1 - d2, d4)), N(d2, L(-1 - d4, cX))
				cY, c_, d1, d3, d5 = N(d5, L(-1 - cY, c_)), N(cY, L(-1 - c_, d1)), N(c_, L(-1 - d1, d3)), N(d1, L(-1 - d3, d5)), N(d3, L(-1 - d5, cY))
				d6, d8, da, dc, de = N(da, L(-1 - dc, de)), N(dc, L(-1 - de, d6)), N(de, L(-1 - d6, d8)), N(d6, L(-1 - d8, da)), N(d8, L(-1 - da, dc))
				d7, d9, db, dd, df = N(db, L(-1 - dd, df)), N(dd, L(-1 - df, d7)), N(df, L(-1 - d7, d9)), N(d7, L(-1 - d9, db)), N(d9, L(-1 - db, dd))
				ct = N(ct, bI[b8])
				cu = cu + bJ[b8]
			end

			bG[1] = ct
			bH[1] = cu
			bG[2] = cv
			bH[2] = cw
			bG[3] = cx
			bH[3] = cy
			bG[4] = cz
			bH[4] = cA
			bG[5] = cB
			bH[5] = cC
			bG[6] = cD
			bH[6] = cE
			bG[7] = cF
			bH[7] = cG
			bG[8] = cH
			bH[8] = cI
			bG[9] = cJ
			bH[9] = cK
			bG[10] = cL
			bH[10] = cM
			bG[11] = cN
			bH[11] = cO
			bG[12] = cP
			bH[12] = cQ
			bG[13] = cR
			bH[13] = cS
			bG[14] = cT
			bH[14] = cU
			bG[15] = cV
			bH[15] = cW
			bG[16] = cX
			bH[16] = cY
			bG[17] = cZ
			bH[17] = c_
			bG[18] = d0
			bH[18] = d1
			bG[19] = d2
			bH[19] = d3
			bG[20] = d4
			bH[20] = d5
			bG[21] = d6
			bH[21] = d7
			bG[22] = d8
			bH[22] = d9
			bG[23] = da
			bH[23] = db
			bG[24] = dc
			bH[24] = dd
			bG[25] = de
			bH[25] = df
		end
	end
end

do
	local function dB(dC, dD, dE, dF)
		local G, dG, dH, dI = {}, 0.0, 0.0, 1.0

		for aK = 1, dF do
			for p = m(1, aK + 1 - #dD), l(aK, #dC) do
				dG = dG + dE * dC[p] * dD[aK + 1 - p]
			end

			local dJ = dG % 2 ^ 24
			G[aK] = j(dJ)
			dG = (dG - dJ) / 2 ^ 24
			dH = dH + dJ * dI
			dI = dI * 2 ^ 24
		end

		return G, dH
	end

	local Y, dK, dL, o, dM, dN = 0, {4, 1, 2, -2, 2}, 4, {1}, aj, ai

	repeat
		dL = dL + dK[dL % 6]
		local aN = 1
		repeat
			aN = aN + dK[aN % 6]

			if aN * aN > dL then
				local dO = dL ^ (1 / 3)
				local dP = dO * 2 ^ 40

				dP = dB({dP - dP % 1}, o, 1.0, 2)

				local H, dQ = dB(dP, dB(dP, dP, 1.0, 4), -1.0, 4)
				local dR = dP[2] % 65536 * 65536 + j(dP[1] / 256)
				local dS = dP[1] % 256 * 16777216 + j(dQ * 2 ^ -56 / 3 * dO / dL)

				if Y < 16 then
					dO = dL ^ (1 / 2)
					dP = dO * 2 ^ 40

					dP = dB({dP - dP % 1}, o, 1.0, 2)

					H, dQ = dB(dP, dP, -1.0, 2)
					local dR = dP[2] % 65536 * 65536 + j(dP[1] / 256)
					local dS = dP[1] % 256 * 16777216 + j(dQ * 2 ^ -17 / dO)
					local Y = Y % 8 + 1
					am[224][Y] = dS
					dM[Y], dN[Y] = dR, dS + dR * ax

					if Y > 7 then
						dM, dN = ao[384], an[384]
					end
				end

				Y = Y + 1
				ah[Y], ag[Y] = dR, dS % aw + dR * ax
				break
			end
		until dL % aN == 0
	until Y > 79
end

for dT = 224, 256, 32 do
	local bS, bT = {}

	if at then
		for aK = 1, 8 do
			bS[aK] = at(ai[aK])
		end
	else
		bT = {}

		for aK = 1, 8 do
			bS[aK] = a9(ai[aK])
			bT[aK] = a9(aj[aK])
		end
	end

	ac(bS, bT, "SHA-512/" .. tostring(dT) .. "\128" .. e("\0", 115) .. "\88", 0, 128)
	an[dT] = bS
	ao[dT] = bT
end

do
	local dU, dV, dW = math.sin, math.abs, math.modf

	for Y = 1, 64 do
		local dR, dS = dW(dV(dU(Y)) * 2 ^ 16)
		ap[Y] = dR * 65536 + j(dS * 2 ^ 16)
	end
end

do
	local dX = 29

	local function dY()
		local W = dX % 2
		dX = V((dX - W) / 2, 142 * W)

		return W
	end

	for Y = 1, 24 do
		local dS, r = 0

		for H = 1, 6 do
			r = r and r * r * 2 or 1
			dS = dS + dY() * r
		end

		local dR = dY() * r
		al[Y], ak[Y] = dR, dS + dR * ay
	end
end

local function dZ(dT, d_)
	local aE, e0, e1 = {unpack(am[dT])}, 0.0, ""

	local function e2(e3)
		if e3 then
			if e1 then
				e0 = e0 + #e3
				local aG = 0

				if e1 ~= "" and #e1 + #e3 >= 64 then
					aG = 64 - #e1
					ab(aE, e1 .. f(e3, 1, aG), 0, 64)
					e1 = ""
				end

				local aC = #e3 - aG
				local e4 = aC % 64
				ab(aE, e3, aG, aC - e4)
				e1 = e1 .. f(e3, #e3 + 1 - e4)

				return e2
			else
				error("Adding more chunks is not allowed after receiving the result", 2)
			end
		else
			if e1 then
				local e5 = {e1, "\128", e("\0", (-9 - e0) % 64 + 1)}

				e1 = nil
				e0 = e0 * 8 / 256 ^ 7

				for aK = 4, 10 do
					e0 = e0 % 1 * 256
					e5[aK] = d(j(e0))
				end

				e5 = b(e5)
				ab(aE, e5, 0, #e5)
				local e6 = dT / 32

				for aK = 1, e6 do
					aE[aK] = U(aE[aK])
				end

				aE = b(aE, "", 1, e6)
			end

			return aE
		end
	end

	if d_ then
		return e2(d_)()
	else
		return e2
	end
end

local function e7(dT, d_)
	local e0, e1, bS, bT = 0.0, "", {unpack(an[dT])}, not as and {unpack(ao[dT])}

	local function e2(e3)
		if e3 then
			if e1 then
				e0 = e0 + #e3
				local aG = 0

				if e1 ~= "" and #e1 + #e3 >= 128 then
					aG = 128 - #e1
					ac(bS, bT, e1 .. f(e3, 1, aG), 0, 128)
					e1 = ""
				end

				local aC = #e3 - aG
				local e4 = aC % 128
				ac(bS, bT, e3, aG, aC - e4)
				e1 = e1 .. f(e3, #e3 + 1 - e4)

				return e2
			else
				error("Adding more chunks is not allowed after receiving the result", 2)
			end
		else
			if e1 then
				local e5 = {e1, "\128", e("\0", (-17 - e0) % 128 + 9)}

				e1 = nil
				e0 = e0 * 8 / 256 ^ 7

				for aK = 4, 10 do
					e0 = e0 % 1 * 256
					e5[aK] = d(j(e0))
				end

				e5 = b(e5)
				ac(bS, bT, e5, 0, #e5)
				local e6 = k(dT / 64)

				if as then
					for aK = 1, e6 do
						bS[aK] = as(bS[aK])
					end
				else
					for aK = 1, e6 do
						bS[aK] = U(bT[aK]) .. U(bS[aK])
					end

					bT = nil
				end

				bS = f(b(bS, "", 1, e6), 1, dT / 4)
			end

			return bS
		end
	end

	if d_ then
		return e2(d_)()
	else
		return e2
	end
end

local function e8(d_)
	local aE, e0, e1 = {unpack(aq, 1, 4)}, 0.0, ""

	local function e2(e3)
		if e3 then
			if e1 then
				e0 = e0 + #e3
				local aG = 0

				if e1 ~= "" and #e1 + #e3 >= 64 then
					aG = 64 - #e1
					ad(aE, e1 .. f(e3, 1, aG), 0, 64)
					e1 = ""
				end

				local aC = #e3 - aG
				local e4 = aC % 64
				ad(aE, e3, aG, aC - e4)
				e1 = e1 .. f(e3, #e3 + 1 - e4)

				return e2
			else
				error("Adding more chunks is not allowed after receiving the result", 2)
			end
		else
			if e1 then
				local e5 = {e1, "\128", e("\0", (-9 - e0) % 64)}

				e1 = nil
				e0 = e0 * 8

				for aK = 4, 11 do
					local e9 = e0 % 256
					e5[aK] = d(e9)
					e0 = (e0 - e9) / 256
				end

				e5 = b(e5)
				ad(aE, e5, 0, #e5)

				for aK = 1, 4 do
					aE[aK] = U(aE[aK])
				end

				aE = g(b(aE), "(..)(..)(..)(..)", "%4%3%2%1")
			end

			return aE
		end
	end

	if d_ then
		return e2(d_)()
	else
		return e2
	end
end

local function ea(d_)
	local aE, e0, e1 = {unpack(aq)}, 0.0, ""

	local function e2(e3)
		if e3 then
			if e1 then
				e0 = e0 + #e3
				local aG = 0

				if e1 ~= "" and #e1 + #e3 >= 64 then
					aG = 64 - #e1
					ae(aE, e1 .. f(e3, 1, aG), 0, 64)
					e1 = ""
				end

				local aC = #e3 - aG
				local e4 = aC % 64
				ae(aE, e3, aG, aC - e4)
				e1 = e1 .. f(e3, #e3 + 1 - e4)

				return e2
			else
				error("Adding more chunks is not allowed after receiving the result", 2)
			end
		else
			if e1 then
				local e5 = {e1, "\128", e("\0", (-9 - e0) % 64 + 1)}

				e1 = nil
				e0 = e0 * 8 / 256 ^ 7

				for aK = 4, 10 do
					e0 = e0 % 1 * 256
					e5[aK] = d(j(e0))
				end

				e5 = b(e5)
				ae(aE, e5, 0, #e5)

				for aK = 1, 5 do
					aE[aK] = U(aE[aK])
				end

				aE = b(aE)
			end

			return aE
		end
	end

	if d_ then
		return e2(d_)()
	else
		return e2
	end
end

local function eb(b5, ec, ed, d_)
	if type(ec) ~= "number" then
		error("Argument 'digest_size_in_bytes' must be a number", 2)
	end

	local e1, bG, bH = "", aa(), ay == 0 and aa()
	local G

	local function e2(e3)
		if e3 then
			if e1 then
				local aG = 0

				if e1 ~= "" and #e1 + #e3 >= b5 then
					aG = b5 - #e1
					af(bG, bH, e1 .. f(e3, 1, aG), 0, b5, b5)
					e1 = ""
				end

				local aC = #e3 - aG
				local e4 = aC % b5
				af(bG, bH, e3, aG, aC - e4, b5)
				e1 = e1 .. f(e3, #e3 + 1 - e4)

				return e2
			else
				error("Adding more chunks is not allowed after receiving the result", 2)
			end
		else
			if e1 then
				local ee = ed and 31 or 6
				e1 = e1 .. (#e1 + 1 == b5 and d(ee + 128) or d(ee) .. e("\0", (-2 - #e1) % b5) .. "\128")
				af(bG, bH, e1, 0, #e1, b5)
				e1 = nil
				local ef = 0
				local eg = j(b5 / 8)
				local eh = {}

				local function ei(b7)
					if ef >= eg then
						af(bG, bH, "\0\0\0\0\0\0\0\0", 0, 8, 8)
						ef = 0
					end

					b7 = j(l(b7, eg - ef))

					if ay ~= 0 then
						for aK = 1, b7 do
							eh[aK] = as(bG[ef + aK - 1 + au])
						end
					else
						for aK = 1, b7 do
							eh[aK] = U(bH[ef + aK]) .. U(bG[ef + aK])
						end
					end

					ef = ef + b7

					return g(b(eh, "", 1, b7), "(..)(..)(..)(..)(..)(..)(..)(..)", "%8%7%6%5%4%3%2%1"), b7 * 8
				end

				local ej = {}
				local ek, el = "", 0

				local function em(en)
					en = en or 1

					if en <= el then
						el = el - en
						local eo = en * 2
						local G = f(ek, 1, eo)
						ek = f(ek, eo + 1)

						return G
					end

					local ep = 0

					if el > 0 then
						ep = 1
						ej[ep] = ek
						en = en - el
					end

					while en >= 8 do
						local eq, er = ei(en / 8)
						ep = ep + 1
						ej[ep] = eq
						en = en - er
					end

					if en > 0 then
						ek, el = ei(1)
						ep = ep + 1
						ej[ep] = em(en)
					else
						ek, el = "", 0
					end

					return b(ej, "", 1, ep)
				end

				if ec < 0 then
					G = em
				else
					G = em(ec)
				end
			end

			return G
		end
	end

	if d_ then
		return e2(d_)()
	else
		return e2
	end
end

local es, et, eu

do
	function es(ev)
		return g(ev, "%x%x", function(ew) return d(tonumber(ew, 16)) end)
	end

	local ex = {
		['+'] = 62,
		['-'] = 62,
		[62] = '+',
		['/'] = 63,
		['_'] = 63,
		[63] = '/',
		['='] = -1,
		['.'] = -1,
		[-1] = '='
	}

	local ey = 0

	for aK, ez in ipairs{'AZ', 'az', '09'} do
		for eA = c(ez), c(ez, 2) do
			local eB = d(eA)
			ex[eB] = ey
			ex[ey] = eB
			ey = ey + 1
		end
	end

	function et(eC)
		local G = {}

		for aJ = 1, #eC, 3 do
			local eD, eE, eF, eG = c(f(eC, aJ, aJ + 2) .. '\0', 1, -1)
			G[#G + 1] = ex[j(eD / 4)] .. ex[eD % 4 * 16 + j(eE / 16)] .. ex[eF and eE % 16 * 4 + j(eF / 64) or -1] .. ex[eG and eF % 64 or -1]
		end

		return b(G)
	end

	function eu(eH)
		local G, eI = {}, 3

		for aJ, eB in h(g(eH, '%s+', ''), '()(.)') do
			local eJ = ex[eB]

			if eJ < 0 then
				eI = eI - 1
				eJ = 0
			end

			local Y = aJ % 4

			if Y > 0 then
				G[-Y] = eJ
			else
				local eD = G[-1] * 4 + j(G[-2] / 16)
				local eE = G[-2] % 16 * 16 + j(G[-3] / 4)
				local eF = G[-3] % 4 * 64 + eJ
				G[#G + 1] = f(d(eD, eE, eF), 1, eI)
			end
		end

		return b(G)
	end
end

local eK

local function eL(aF, dF, eM)
	return g(aF, ".", function(aM) return d(V(c(aM), eM)) end) .. e(d(eM), dF - #aF)
end

local function eN(eO, eP, d_)
	local eQ = eK[eO]

	if not eQ then
		error("Unknown hash function", 2)
	end

	if #eP > eQ then
		eP = es(eO(eP))
	end

	local eR = eO()(eL(eP, eQ, 0x36))
	local G

	local function e2(e3)
		if not e3 then
			G = G or eO(eL(eP, eQ, 0x5C) .. es(eR()))

			return G
		elseif G then
			error("Adding more chunks is not allowed after receiving the result", 2)
		else
			eR(e3)

			return e2
		end
	end

	if d_ then
		return e2(d_)()
	else
		return e2
	end
end

local eS = {
	md5 = e8,
	sha1 = ea,
	sha224 = function(d_) return dZ(224, d_) end,
	sha256 = function(d_) return dZ(256, d_) end,
	sha512_224 = function(d_) return e7(224, d_) end,
	sha512_256 = function(d_) return e7(256, d_) end,
	sha384 = function(d_) return e7(384, d_) end,
	sha512 = function(d_) return e7(512, d_) end,
	sha3_224 = function(d_) return eb((1600 - 2 * 224) / 8, 224 / 8, false, d_) end,
	sha3_256 = function(d_) return eb((1600 - 2 * 256) / 8, 256 / 8, false, d_) end,
	sha3_384 = function(d_) return eb((1600 - 2 * 384) / 8, 384 / 8, false, d_) end,
	sha3_512 = function(d_) return eb((1600 - 2 * 512) / 8, 512 / 8, false, d_) end,
	shake128 = function(ec, d_) return eb((1600 - 2 * 128) / 8, ec, true, d_) end,
	shake256 = function(ec, d_) return eb((1600 - 2 * 256) / 8, ec, true, d_) end,
	hmac = eN,
	hex2bin = es,
	base642bin = eu,
	bin2base64 = et
}

eK = {
	[eS.md5] = 64,
	[eS.sha1] = 64,
	[eS.sha224] = 64,
	[eS.sha256] = 64,
	[eS.sha512_224] = 128,
	[eS.sha512_256] = 128,
	[eS.sha384] = 128,
	[eS.sha512] = 128,
	[eS.sha3_224] = (1600 - 2 * 224) / 8,
	[eS.sha3_256] = (1600 - 2 * 256) / 8,
	[eS.sha3_384] = (1600 - 2 * 384) / 8,
	[eS.sha3_512] = (1600 - 2 * 512) / 8
}

return eS
