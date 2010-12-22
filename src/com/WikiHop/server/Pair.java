package com.WikiHop.server;
import java.io.Serializable;

public class Pair<ClassA extends Serializable, ClassB extends Serializable> implements Serializable {

	private static final long serialVersionUID = 0xDEADBEEF;

    protected ClassA itemA;
    protected ClassB itemB;

    public Pair() {}

    public Pair(ClassA itemA, ClassB itemB) {
        this.itemA = itemA;
        this.itemB = itemB;
    }

    public void setItemA(ClassA itemA) { this.itemA = itemA; }
    public ClassA getItemA() { return itemA; }
    public void setItemB(ClassB itemB) { this.itemB = itemB; }
    public ClassB getItemB() { return itemB; }

    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null) return false;
        if (getClass() != obj.getClass()) return false;
        Pair<?,?> other = (Pair<?,?>) obj;
        if (itemA == null) {
            if (other.itemA != null) return false;
        } else if (!itemA.equals(other.itemA)) return false;
        if (itemB == null) {
            if (other.itemB != null) return false;
        } else if (!itemB.equals(other.itemB)) return false;
        return true;
    }

    @Override
    public String toString() {
        return "Pair<" + getClass(itemA) + ", " + getClass(itemB) + "> (" + itemA + ", " + itemB + ")";
    }

    private Class<?> getClass(Object o) {
        return (o != null ? o.getClass() : null);
    }
}

