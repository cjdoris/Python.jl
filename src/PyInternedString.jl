"""
    PyInternedString(x::String)

Convert `x` to an interned Python string.

This can provide a performance boost when using strings to index dictionaries or get attributes.

See also [`@pystr_str`](@ref).
"""
mutable struct PyInternedString
    ptr::CPyPtr
    val::String
    PyInternedString(x::String) = finalizer(pyref_finalize!, new(CPyPtr(0), x))
end
export PyInternedString

ispyreftype(::Type{PyInternedString}) = true
pyptr(x::PyInternedString) = begin
    ptr = x.ptr
    if isnull(ptr)
        s = Ref{CPyPtr}()
        s[] = C.PyUnicode_From(x.val)
        isnull(s[]) && return ptr
        C.PyUnicode_InternInPlace(s)
        ptr = x.ptr = s[]
    end
    ptr
end
Base.unsafe_convert(::Type{CPyPtr}, x::PyInternedString) = checknull(pyptr(x))
Base.show(io::IO, x::PyInternedString) = begin
    show(io, typeof(x))
    print(io, '(')
    show(io, x.val)
    print(io, ')')
end

"""
    pystr"..." :: PyInternedString

Literal syntax for an interned Python string.
"""
macro pystr_str(s::String)
    PyInternedString(s)
end
export @pystr_str
